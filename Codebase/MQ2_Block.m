classdef MQ2_Block < matlab.System ...
    & matlab.system.mixin.CustomIcon

    % Digital twin of MQ-2 (SnO2) gas sensor with heater
    % Inputs : tSim, T_C (°C), RH_pct (%), ppm_vec [LPG; CH4; H2; CO]
    % Outputs: Vout (V), Rs_ohm, ppm_est (LPG-equivalent), P_heater (W)

    properties (Nontunable)
        % Electrical
        Vc = 5.0;            % circuit voltage (V)
        RL = 10e3;           % load resistor (ohm)
        % Discrete sampling
        Ts = 0.1;            % sample time (s)
        % Dynamics
        tau_resp = 15.0;     % rise time constant (s)
        tau_rec  = 45.0;     % recovery time constant (s)
        % Temperature / humidity correction (small-signal, around 25C/65%RH)
        alpha_T = -0.004;    % Rs change per °C (neg: hotter -> lower Rs)
        alpha_H = +0.003;    % Rs change per %RH (pos: wetter -> higher Rs)
        % Calibration
        R0 = 10e3;           % Rs at C0 ppm LPG (reference)
        C0 = 1000;           % reference ppm
        % Gas model coefficients  Rs/R0 = a * C^(-b)
        a_LPG = 1.0;  b_LPG = 0.45;
        a_CH4 = 1.4;  b_CH4 = 0.40;
        a_H2  = 0.8;  b_H2  = 0.42;
        a_CO  = 1.8;  b_CO  = 0.36;
        w_LPG = 1.0; w_CH4 = 0.7; w_H2 = 0.6; w_CO = 0.3; % cross-weights
        % Noise
        sigma_Rs = 0.02;     % relative noise on Rs
        % Heater
        HeaterPower_W = 0.75;  % nominal MQ-2 heater power (5V, ~150mA)
        Warmup_s = 60;         % seconds to reach stable operation
    end

    % --- CRITICAL CHANGE: ONLY 1 STATE VARIABLE ---
    properties (DiscreteState)
        StateVec; % Vector: [Rs; Rs_ss; warmed]
    end

    methods (Access=protected)
        function icon = getIconImpl(~), icon = "MQ-2"; end

        function sts = getSampleTimeImpl(obj)
            sts = createSampleTime(obj,'Type','Discrete','SampleTime',obj.Ts);
        end

        function setupImpl(obj, ~, ~, ~, ~)
            % Initialize vector: [Rs, Rs_ss, warmed]
            obj.StateVec = [obj.R0; obj.R0; 0];
        end

        function [Vout, Rs_out, ppm_est, Pheat] = stepImpl(obj, tSim, T_C, RH_pct, ppm_vec)
            % --- 1. Unpack State Vector ---
            Rs     = obj.StateVec(1);
            Rs_ss  = obj.StateVec(2);
            warmed = obj.StateVec(3);

            % --- 2. Sensor Logic ---
            C_LPG = max(ppm_vec(1),0);
            C_CH4 = max(ppm_vec(2),0);
            C_H2  = max(ppm_vec(3),0);
            C_CO  = max(ppm_vec(4),0);

            % Base Rs_i from power-law curves (ppm->Rs)
            RsL = obj.R0 * obj.a_LPG * max(C_LPG,1)^(-obj.b_LPG);
            RsM = obj.R0 * obj.a_CH4 * max(C_CH4,1)^(-obj.b_CH4);
            RsH = obj.R0 * obj.a_H2  * max(C_H2 ,1)^(-obj.b_H2 );
            RsC = obj.R0 * obj.a_CO  * max(C_CO ,1)^(-obj.b_CO );

            Gmix = obj.w_LPG./RsL + obj.w_CH4./RsM + obj.w_H2./RsH + obj.w_CO./RsC;
            Rs_mix = 1/max(Gmix,1e-9);

            fT  = 1 + obj.alpha_T*(T_C - 25);
            fRH = 1 + obj.alpha_H*(RH_pct - 65);
            Rs_corr = Rs_mix * fT * fRH;

            % Warm-up logic
            if warmed == 0 && tSim >= obj.Warmup_s
                warmed = 1;
            end
            
            if warmed == 0
                Rs_target = max(Rs_corr, obj.R0*10);
            else
                Rs_target = Rs_corr;
            end

            % Filter dynamics
            if Rs_target < Rs
                tau = obj.tau_resp;
            else
                tau = obj.tau_rec;
            end
            alpha = exp(-obj.Ts/max(tau,1e-3));
            Rs = alpha*Rs + (1-alpha)*Rs_target;

            % Noise
            Rs = max(200, Rs .* (1 + obj.sigma_Rs*randn()));

            % Outputs
            Vout = obj.Vc * (obj.RL / (obj.RL + obj.Rs));
            Rs_out = Rs;
            ppm_est = obj.C0 * ( (Rs_out/obj.R0)/obj.a_LPG )^(-1/obj.b_LPG);
            Pheat = obj.HeaterPower_W;

            % --- 3. Pack State Vector ---
            obj.StateVec = [Rs; Rs_ss; warmed];
        end

        % --- SPECIFICATION: Returns 1 output for 1 State ---
        function ds = getDiscreteStateSpecificationImpl(obj, name)
             ds = matlab.system.DiscreteStateSpec(name);
             ds.SampleTime = obj.Ts;
             ds.DataType = 'double';
             ds.Size = [3 1]; % It is a vector of size 3
        end

        function resetImpl(obj)
            obj.StateVec = [obj.R0; obj.R0; 0];
        end

        % I/O sizing 
        function [o1,o2,o3,o4] = getOutputSizeImpl(~)
            o1=[1 1]; o2=[1 1]; o3=[1 1]; o4=[1 1];
        end
        function [o1,o2,o3,o4] = getOutputDataTypeImpl(~)
            o1='double'; o2='double'; o3='double'; o4='double';
        end
        function [o1,o2,o3,o4] = isOutputComplexImpl(~)
            o1=false; o2=false; o3=false; o4=false;
        end
        function [o1,o2,o3,o4] = isOutputFixedSizeImpl(~)
            o1=true; o2=true; o3=true; o4=true;
        end
    end
end
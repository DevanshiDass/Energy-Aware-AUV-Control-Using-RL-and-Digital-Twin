classdef Ocean_API_Block < matlab.System ...
       % & matlab.system.mixin.Propagates ...
       % & matlab.system.mixin.CustomIcon

    % PRE-REQUISITE: You must have 'envCache' in your workspace!
    % (Run 'fetch_env_data.m' first)

    methods (Access = protected)

        function [current_x, current_y, seaTemp, humidity, wave_energy, gas_ppm_field] = stepImpl(~, tSim)
            % Default safety values
            current_x = 0; current_y = 0;
            seaTemp = 25; humidity = 65;
            wave_energy = 0; gas_ppm_field = 0;

            try
                % 1. Get data from Workspace (Cached)
                data = evalin('base', 'envCache');
                
                % 2. Calculate Index (1 hour = 3600 seconds)
                idx = floor(tSim/3600) + 1;
                
                % Safety check for index
                if isfield(data, 'SeaTemp')
                    idx = max(1, min(idx, length(data.SeaTemp)));
                    
                    % 3. Extract Raw Data
                    cs = data.CurrentSpd(idx);       % Speed
                    cd = data.CurrentDir(idx);       % Direction (rad)
                    seaTemp = data.SeaTemp(idx);     % Temp
                    waveH = data.WaveH(idx);         % Wave Height
                else
                    % Fallback if envCache exists but is partial
                    cs = 0; cd = 0; waveH = 0;
                end
                
                % 4. Compute Derived Physics
                current_x = cs * cos(cd);
                current_y = cs * sin(cd);
                
                % Simple models for the rest
                humidity = 60 + 15*sin(0.01*tSim);
                wave_energy = waveH * 10; % Simplified energy metric
                
                % Gas Plume Simulation (Source at 0,0)
                gas_ppm_field = 50 + 30*sin(0.005*tSim); 

            catch
                % Fallback if envCache is missing entirely
            end
        end

        function n = getNumInputsImpl(~),  n = 1; end      
        function n = getNumOutputsImpl(~), n = 6; end      

        function names = getInputNamesImpl(~),  names = "tSim"; end
        function names = getOutputNamesImpl(~)
            names = ["current_x","current_y","seaTemp","humidity","wave_energy","gas_ppm_field"];
        end

        % --- THE FIX: Return 6 separate values for the 6 output ports ---
        
        function [o1, o2, o3, o4, o5, o6] = getOutputSizeImpl(~)
            o1=[1 1]; o2=[1 1]; o3=[1 1]; o4=[1 1]; o5=[1 1]; o6=[1 1];
        end
        
        function [o1, o2, o3, o4, o5, o6] = getOutputDataTypeImpl(~)
            o1='double'; o2='double'; o3='double'; o4='double'; o5='double'; o6='double';
        end
        
        function [o1, o2, o3, o4, o5, o6] = isOutputComplexImpl(~)
            o1=false; o2=false; o3=false; o4=false; o5=false; o6=false;
        end
        
        function [o1, o2, o3, o4, o5, o6] = isOutputFixedSizeImpl(~)
            o1=true; o2=true; o3=true; o4=true; o5=true; o6=true;
        end
    end
end
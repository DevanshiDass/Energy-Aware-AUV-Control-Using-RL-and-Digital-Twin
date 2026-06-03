classdef Gas_Environment_Block < matlab.System ...
        & matlab.system.mixin.CustomIcon

    properties
        base_ppm = 5;        % background concentration (ppm)
        leak_ppm = 200;      % max concentration during leak (ppm)
        growth_rate = 0.02;  % how fast leak spreads
        decay_rate = 0.005;  % how slow leak fades
    end

    methods (Access = protected)
        function ppm_out = stepImpl(obj, tSim)
            % Environmental Gas Concentration Model (No position needed)

            % Leak plume model: rises, peaks, then slowly dissipates
            % You can adjust this formula later.
            plume = obj.leak_ppm * (1 - exp(-obj.growth_rate * tSim)) .* exp(-obj.decay_rate * tSim);

            % Final gas concentration
            ppm_out = obj.base_ppm + plume;
        end

        function icon = getIconImpl(~)
            icon = "Gas Field";
        end
    end
end

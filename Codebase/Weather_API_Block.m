classdef Weather_API_Block < matlab.System & matlab.system.mixin.CustomIcon
    % PRE-REQUISITE: You must have 'envCache' in your workspace!
    
    methods (Access = protected)
        function [T_C, RH_pct] = stepImpl(~, tSim)
            % Get data from the base workspace variable 'envCache'
            % This avoids calling the API every millisecond
            try
                data = evalin('base', 'envCache'); 
                
                % Convert time to index (1 hour = 3600 seconds)
                idx = floor(tSim/3600) + 1;
                
                % Safety check for index out of bounds
                idx = max(1, min(idx, length(data.temp)));
                
                T_C = data.temp(idx);
                RH_pct = data.humid(idx);
            catch
                % Fallback if variable is missing
                T_C = 25; 
                RH_pct = 50;
            end
        end

        function icon = getIconImpl(~)
            icon = "Weather Cache";
        end
    end
end
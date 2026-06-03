classdef DVL_Block < matlab.System & matlab.system.mixin.CustomIcon
    properties (Nontunable)
        Ts = 0.1;
        noise = 0.03;
        max_depth = 60;
    end
    methods (Access=protected)
        function sts=getSampleTimeImpl(obj),sts=createSampleTime(obj,'Type','Discrete','SampleTime',obj.Ts);end
        function icon=getIconImpl(~),icon="DVL";end
        function vel_meas=stepImpl(obj, vel_true, depth)
            if depth < obj.max_depth
                vel_meas = vel_true + obj.noise*randn(3,1);
            else
                vel_meas = [NaN;NaN;NaN]; % bottom lock lost
            end
        end
    end
end

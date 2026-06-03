classdef Magnetometer_Block < matlab.System & matlab.system.mixin.CustomIcon
    properties (Nontunable)
        Ts = 0.1;  
        yaw_noise = deg2rad(1.5);
    end
    methods (Access=protected)
        function sts=getSampleTimeImpl(obj),sts=createSampleTime(obj,'Type','Discrete','SampleTime',obj.Ts);end
        function icon=getIconImpl(~),icon="MAG";end
        function yaw_meas=stepImpl(obj, yaw_true)
            yaw_meas = yaw_true + obj.yaw_noise*randn();
        end
    end
end

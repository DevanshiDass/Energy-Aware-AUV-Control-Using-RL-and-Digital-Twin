classdef Depth_Block < matlab.System & matlab.system.mixin.CustomIcon
    properties (Nontunable)
        Ts = 0.1;  
        noise = 0.02;
    end
    methods (Access=protected)
        function sts = getSampleTimeImpl(obj), sts = createSampleTime(obj,'Type','Discrete','SampleTime',obj.Ts); end
        function icon = getIconImpl(~), icon = "Depth"; end
        function z_meas = stepImpl(obj, z_true)
            z_meas = z_true + obj.noise*randn();
        end
    end
end

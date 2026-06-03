classdef IMU_Block < matlab.System & matlab.system.mixin.CustomIcon
    properties (Nontunable)
        Ts = 0.1;   % IMU sample time (100 Hz)
        accel_noise = 0.02;   % m/s^2 noise
        gyro_noise  = 0.002;  % rad/s noise
        bias_accel = [0.05;0.05;0.05];
        bias_gyro  = [0.002;0.002;0.002];
    end
    methods (Access=protected)
        function sts = getSampleTimeImpl(obj), sts = createSampleTime(obj,'Type','Discrete','SampleTime',obj.Ts); end
        function icon = getIconImpl(~), icon = "IMU"; end
        function [acc_meas, gyro_meas] = stepImpl(obj, acc_true, gyro_true)
            acc_meas  = acc_true  + obj.bias_accel + obj.accel_noise*randn(3,1);
            gyro_meas = gyro_true + obj.bias_gyro  + obj.gyro_noise*randn(3,1);
        end
    end
end

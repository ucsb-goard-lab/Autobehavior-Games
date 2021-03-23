classdef JoystickGameManager < MainGameManager
    properties (Access = protected)
        side;
    end
    methods (Access = public)
        function obj = DelayedServoOpen(obj)
           obj.ioDevice.DelayedCall('OpenSide',obj.stimPauseTime+obj.servoDelay,obj.side);
        end
        function out = ChooseSide(obj)
            out = obj.ChooseSide@MainGameManager();
            obj.side = out;
        end
    end
end
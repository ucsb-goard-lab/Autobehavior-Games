classdef GratedCircleController < GameObject
    properties (Constant)
        maxSpeed = 250%pixels per second
    end
    properties (Access = protected)
        targetObj
        ioDevice
    end
    methods (Access = public)
        function obj = GratedCircleController(gratedCirc,io)
            obj.targetObj = gratedCirc;
            obj.ioDevice = io;
        end
        function obj = Update(obj)
            if(isempty(obj.targetObj)) return; end
            obj.targetObj.SetVelocity(obj.ioDevice.ReadJoystick()*obj.maxSpeed,1);
        end       
    end
end
classdef JoystickGratedCircle < GratedCircle
    
    methods(Access = public)
        function obj = Awake(obj)
           obj.initialOffset = 2*obj.radius;
        end
    end
end

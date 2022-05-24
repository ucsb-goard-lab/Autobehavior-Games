classdef IODevice < GameObject
    methods (Access = public)
        function out = ReadJoystick(obj)
            out = 0;
        end
        function out = ReadIR(obj)
            out = false;
        end
        function out = ReadLick(obj)
            out = false;
        end
	function out = ManuallyGiveWater(obj)
		out = GetKey('w');
	end
        function obj = GiveWater(obj,time)
        end
        function [] = CloseServos(obj)
        end
        function [] = OpenServos(obj)
        end
        function [] = OpenSide(obj,side)
        end
    end
end

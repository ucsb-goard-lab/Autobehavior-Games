classdef EscapeQuit < GameObject
    methods (Access = public)
        function obj = Awake(obj)
            KbCheck();
        end
        function obj = Update(obj)
                   if GetKey('ESC') || GetKey('ESCAPE')
                       obj.Game.ManualQuit(); 
                   end
        end
    end
end
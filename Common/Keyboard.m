classdef Keyboard < IODevice
methods (Access = public)
    function obj = Keyboard()
    end
    function out = ReadJoystick(obj)
        out = obj.TrinaryInput('rightarrow','leftarrow');
    end
    function out = ReadUpDown(obj)
        out = obj.TrinaryInput('downarrow','uparrow');
    end
    function out = TrinaryInput(obj,upKey,downKey)
        r = GetKey(upKey);
        l = GetKey(downKey);
        out = 0;
        if xor(r,l)
            out = 1;
            if l
                out = -out; 
            end
        end
    end
    function out = ReadIR(obj)
        out = GetKey('i');
    end
    function out = ReadLick(obj)
        out = GetKey('l');
    end
end
end
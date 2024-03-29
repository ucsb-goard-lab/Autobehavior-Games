clc;
clear all;

% requestInput();
port = 'com5';
addpath('Common');
addpath('PTB-Game-Engine/GameEngine');
fprintf("connecting...\n");
io = HardwareIOGen5(port);
io.Awake();
fprintf("arduino setup complete\n");

while ~GetKey('ESC')
    if GetKey("s")
        try
        io.GiveWater(1);
        catch
        end
    else
        io.CloseSolenoid();
    end
end

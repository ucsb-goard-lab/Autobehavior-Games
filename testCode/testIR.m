clc
clear all;
requestInput();
% port = 'com5';
addpath('Common');
addpath('PTB-Game-Engine/GameEngine');
fprintf("connecting...\n");
io = HardwareIOGen5(port);
% io = Gen5Rig(port);
io.Awake();
fprintf("arduino setup complete\n");
while ~GetKey("ESC")
    clc;
    if io.ReadIR()
        fprintf("IR Sensor Obstructed\n");
    else
        fprintf("0\n");
    end
    pause(0.1);
end
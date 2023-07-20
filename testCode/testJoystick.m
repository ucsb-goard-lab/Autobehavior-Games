clc
clear all;
% requestInput();
port = 'com16';
addpath('Common');
addpath('PTB-Game-Engine/GameEngine');
fprintf("connecting...\n");
io = HardwareIOGen5(port);
io.Awake();
fprintf("arduino setup complete\n");

io.OpenServos();

while ~GetKey("ESC")
    clc;
    
    disp(io.ReadJoystick());
    
    pause(0.1);
end
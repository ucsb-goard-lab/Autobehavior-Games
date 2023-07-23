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

io.PowerServos(true);
io.CloseServos();

while ~GetKey("ESC")
    clc;
    
    disp(readCount(io.encoder));
    
    pause(0.1);
end

io.PowerServos(false);
clc;
clear all;

% port = 'com14';
requestInput();

addpath('Common');
%this task is to train mice to manipulate the joystick, regardless of
%direction
addpath('PTB-Game-Engine/GameEngine');
fprintf("connecting...\n");
io = HardwareIOGen5(port);
io.Awake();
fprintf("arduino setup complete\n");

numEnters = 0;
numLicks = 0;
numDispenses = 0;

%defines a minimum angle that the mouse must turn the joystick to be
%rewarded
turnThreshold = 0.5;

io.PowerServos(true)
io.CloseServos();
% io.PowerServos(false);

while ~GetKey('ESC')
    clc;

    posOnEntry = io.ReadJoystick();

    %if the mouse is in the tube
    if io.ReadIR()
        numEnters = numEnters + 1;
        posCurrent = io.ReadJoystick();
        disp(num2str(abs(posCurrent - posOnEntry)))

        %if the mouse turns the joystick past the threshold, give water
        while io.ReadIR()
            if abs(posCurrent - posOnEntry) > turnThreshold
                %give water
    %             try
    %             io.GiveWater(1);
    %             catch
    %             end
%                 io.CloseSolenoid();
                clc;
                numDispenses = numDispenses + 1;
                fprintf("Water dispensed");
                break
            end
        end

    end

end
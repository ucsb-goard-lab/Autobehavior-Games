%%%DO NOT USE%%%
% for some reason this script will always detect a lick
%even when there is none.

clc;
clear all;

% port = 'com14';
requestInput();

% setSaveDirectory(saveDir);

addpath('Common');
%this task is to train mice to enter the tube
addpath('PTB-Game-Engine/GameEngine');
fprintf("connecting...\n");
io = HardwareIOGen5(port);
io.Awake();
fprintf("arduino setup complete\n");

numLicks = 0;
numDispenses = 0;
minDelayBetweenRewards = 0.1;

io.PowerServos(true)
io.CloseServos();
io.PowerServos(false);

while ~GetKey('ESC') && numDispenses < numTrials
    clc;

    %if the mouse enters the tube, give a little bit of water
    if io.ReadIR()
        fprintf("Mouse Detected");

        %give water
%         try
%         io.GiveWater(1);
%         catch
%         end
%         pause(.3);
%         io.CloseSolenoid();

        numDispenses = numDispenses + 1;
        fprintf("Water dispensed");

        %while the mouse is still in the tube, check to see if it licks
        while io.ReadIR()
            clc;
            pause(0.1);
            if io.ReadLick() % ??? always detects lick ???
                numLicks = numLicks + 1;
                fprintf("Lick Detected");
                break
            end
        end

        while io.ReadIR()
            %stay in the loop until the mouse leaves to only detects one lick
        end

    end
    
    disp(['NumDispenses: ' num2str(numDispenses)]);
    disp(['Num Licks: ' num2str(numLicks)]);
    pause(0.1);
end
clc;
disp(['Number of licks: ' num2str(numLicks) ]);
disp(['Number of dispenses: ' num2str(numDispenses) ]);
disp(['Mouse licked ' num2str(numLicks/numDispenses * 100) '% of the time.'])

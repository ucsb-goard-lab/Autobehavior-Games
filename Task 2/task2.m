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
%defines a minimum angle
turnThreshold = 120; %about a quarter turn, full range is ~480

results = Results(mouseID,numTrials,sessionNum,'task2Training',natBackground);
results.setSaveDirectory(saveDir);

soundMaker = SoundMaker();

io.PowerServos(true)
io.OpenServos();
pause(2);
io.PowerServos(false);

while numEnters  < numTrials && ~GetKey("ESC")
    clc;

    if results.currentTrial == numDispenses
        results.StartTrial(0,0,GetSecs());
    end

    %if the mouse is in the tube, read the orientation fo the joystick to
    %use as a reference
    if io.ReadIR()

        numEnters = numEnters + 1;
        posOnEntryRaw = readCount(io.encoder);
        posCurrentRaw = posOnEntryRaw;
        posOnEntry = io.ReadJoystick();
        posCurrent = posOnEntry;
        waterDispenseTime = 0.2

        %if the mouse turns the joystick past the threshold, give water
        while ~GetKey('ESC') && io.ReadIR()
            clc;
            posCurrentRaw = readCount(io.encoder);
            posCurrent = io.ReadJoystick();
            fprintf('posCurrentRaw = %f\n',posCurrentRaw);
            fprintf('posOnEntryRaw = %f\n',posOnEntryRaw);
            disp(posCurrentRaw - posOnEntryRaw);

            %if the mouse turns the joystick past the threshold, give water
            if abs(posCurrentRaw - posOnEntryRaw) >= 50
                %give water
                try
                    io.GiveWater(1);
                    results.LogJoystickManipulation(GetSec());
                catch
                end
                pause(waterDispenseTime);
                io.CloseSolenoid();
                
                soundMaker.RewardNoise();
                
                clc;
                numDispenses = numDispenses + 1;
                fprintf("Water dispensed");

                if posCurrent - posOnEntry > 0 %right turn
                    results.LogJoy(posCurrent, 1, GetSecs());
                else %left turn
                    results.LogJoy(posCurrent, -1, GetSecs());
                end
                break
            end
        end

        %check if the mouse licks
        while io.ReadIR()
            clc;
            if io.ReadLick()
                fprintf("LICKMETER ACTUATED\n");
                numLicks = numLicks + 1;
                results.LogLick(GetSecs());
                
                break
            else
                fprintf("0\n");
            end
        end

        %last while loop to wait for mouse to leave
        while ~GetKey('ESC') && io.ReadIR()
        end
        
        results.EndTrial(GetSecs());
        
        io.PowerServos(true)
        io.CloseServos();
        pause(2);
        io.OpenServos()
        pause(2);
        io.PowerServos(false);

        

    end

    fprintf(['Num Enters: ' num2str(numEnters) '\n']);
    fprintf(['NumDispenses: ' num2str(numDispenses) '\n']);
    fprintf(['Num Licks: ' num2str(numLicks) '\n']);
    results.save();
    pause(0.1);

end

clc;
fprintf('NumEnters: %f\n', fix(numEnters));
fprintf('NumDispenses: %f\n', fix(numDispenses));
fprintf('Num Licks: %f\n', fix(numLicks));
fprintf('Mouse licked %f %% of the time.\n', fix(numEnters / numDispenses * 10000) / 100);
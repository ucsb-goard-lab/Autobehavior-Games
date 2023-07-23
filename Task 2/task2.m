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

io.PowerServos(true)
io.CloseServos();
% io.PowerServos(false);

while ~GetKey('ESC') &&numEnters < numTrials
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

        %if the mouse turns the joystick past the threshold, give water
        while io.ReadIR()
            clc;
            posCurrentRaw = readCount(io.encoder);
            posCurrent = io.ReadJoystick();
            disp(num2str(abs(posCurrent - posOnEntry)));

            %if the mouse turns the joystick past the threshold, give water
            if abs(posCurrentRaw - posOnEntryRaw) > turnThreshold
                %give water
    %             try
    %             io.GiveWater(1);
    %             catch
    %             end
    %             pause(0.3);
    %             io.CloseSolenoid();
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
        while io.ReadIR()
        end

        results.EndTrial(GetSecs());

    end

    fprintf(['Num Enters: ' num2str(numEnters) '\n']);
    fprintf(['NumDispenses: ' num2str(numDispenses) '\n']);
    fprintf(['Num Licks: ' num2str(numLicks) '\n']);
    pause(0.1);

end

results.save();
clc;
fprintf('NumDispenses: %f\n', fix(numDispenses));
fprintf('Num Licks: %f\n', fix(numLicks));
fprintf('Mouse licked %f %% of the time.\n', fix(numLicks / numDispenses * 10000) / 100);
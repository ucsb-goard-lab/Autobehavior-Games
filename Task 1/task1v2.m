clc
clear all;
requestInput();
% port = 'COM14';
addpath('Common');
addpath('PTB-Game-Engine/GameEngine');
fprintf("connecting...\n");
io = HardwareIOGen5(port);
io.Awake();
fprintf("arduino setup complete\n");

numDispenses = 0;
numLicks = 0;
delayRewards = 0;
waterDispenseTime = 0.2;

results = Results(mouseID,numTrials,sessionNum,'task1Training',natBackground);
results.setSaveDirectory(saveDir);

while ~GetKey("ESC") && numDispenses < numTrials
    clc;
    if results.currentTrial == numDispenses
        results.StartTrial(0,0,GetSecs());
    end
    
    if io.ReadIR()

        %give water
        try
            io.GiveWater(1);
        catch
        end
        pause(waterDispenseTime);
        io.CloseSolenoid();

        numDispenses = numDispenses + 1;
        fprintf(num2str(numDispenses));

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

        while io.ReadIR()
        end

        results.EndTrial(GetSecs());
       
    end

    fprintf(['NumDispenses: ' num2str(numDispenses) '\n']);
    fprintf(['Num Licks: ' num2str(numLicks) '\n']);
    pause(0.1);
end
results.save();
clc;
fprintf('NumDispenses: %f\n', fix(numDispenses));
fprintf('Num Licks: %f\n', fix(numLicks));
fprintf('Mouse licked %f %% of the time.\n', fix(numLicks / numDispenses * 10000) / 100);

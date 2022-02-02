addpath('PTB-Game-Engine/GameEngine');     %game engine
addpath('Common');                         %files used by all the games (main, lickspout only, and joystick only)
addpath('Main Game');                      %files used by this game
addpath('Img');                            %image files

%clear workspace and close com ports
clearAll;

contrastList = 1;%[2.^(0:6), 100] / 100; % Specify the pool of contrasts for the circle
requestInput;%get rig specific data from user via GUI

developerMode = (mouseID == '0');%if user sets mouse name to zero, we will run in developer mode (no saving data or emailing errors)

%if we are iiin developer mode, give user the option to use keyboard as iniput
if developerMode
    choice = menu('Keyboard or Autobehavior Rig input?','Keyboard','Rig');
    usingKeyboard = choice==1;
else
    usingKeyboard = false;
end

%what percent of the screen do we want to render to?
%[min x, min y, max x, max y] 0 and 1 are the edges of the screen
% this is used for multiple monitor setups like in the headfixed rigs
rect = [0,0,1,1];

secondarySaveDir = 'C:/Autobehavior Data/';

day = 1; % day 1
while day < 365 % days
    instrreset; % clear the COM ports, so we can re-connect to the arduino
%     io = Gen5Rig(port);
    io = Keyboard();
    %initialize objects
    results = Results(mouseID,numTrials,sessionNum,'closedLoopTraining',natBackground);
    results.setSaveDirectory(saveDir, secondarySaveDir);
    renderer = Renderer(screenNum,0.5,rect);%(screenNumber,default background color,rect to render to)
    grating = GratedCircle(contrastList); % You can provide a pool of possible opacities for the grated circle
    greenCirc = TargetRing;
    if natBackground
        background = NaturalBackground('NaturalScene_stacked.png');
        %background_inverted = NaturalBackground('backgroundForest.png', [2, 1]);
        %background = RandomizedBackground('backgroundDot.png',40,[2,1]);%(image, quantity, [x range, y range])
        background.SetParent(grating);%make background the child of grating so that the move in unison
        background.RenderAfter(grating);%make background render  last
    end
    grating.RenderAfter(greenCirc);%make grating render behind green circle
    iescape = EscapeQuit;%object that makes game quit if you press the escape key
    sound = SoundMaker;
    
    controller = GratedCircleController(grating, io);
    
    %manager handles game logic. Constructor params are references to objects
    %that it interacts with
    
    if natBackground
        manager = MainGameManager(grating,greenCirc,background,controller,io,sound,results, 1); % 1 for continuous trials
    else
        manager = MainGameManager(grating,greenCirc,[],controller,io,sound,results, 1);
    end
    
    manager.SetMaxTrials(numTrials);
    manager.SetAllowIncorrect(reward);
    manager.SetTrainingMode(trainMode);
    
    ge = GameEngine;
    %game engine has built in error handling, but we want to do email error
    %notification outside of that
    %the reason why is that built in error handling deals with safety stuff
    %like making sure the solenoids are shut off if an error occurs.
    % emailing takes a long time, so if that were to happen before the solenoid
    % error function, the mouse cage could get flooded
    try
        ge.Start();
    catch e
        % msg = char(getReport(e,'extended','hyperlinks','off'));
        % subject = "Autobehaviour ERROR: rig "+string(rig)+" mouse "+string(mouseID);
        % emailer.Send(subject,msg);
        rethrow(e);
    end
    
    if manual_quit == 1 % immediately quit if manually escaped
        break
    end
    
    [h, m] = hms(datetime); % get current time
    if manager.GetNumberOfGamesPlayed() >= numTrials % to prevent there being like 500000 trials in one day
        fprintf('Reached maximum number of trials (%d)\n', numTrials)
        while ~all([h, m] == [02, 00]) % wait until 0200 to restart trails
            [h, m] = hms(datetime); % update
        end
    else
        end_h = h;
        end_m = m + 1;
        while ~all([h, m] == [end_h, end_m]) % wait 1 minute
            [h, m] = hms(datetime); % update
        end
    end
    
    % if manager.GetNumberOfGamesPlayed()>=numTrials
    %     msg = char("mouse "+string(mouseID) + " on rig " + string(rig) + " has successfully completed " + string(numTrials) + " trials.");
    %     subject = "Autobehaviour SUCCESS: rig "+string(rig)+" mouse "+string(mouseID);
    %     emailer.Send(subject,msg);
    % end
    
    
    % increment everything
    day = day + 1;
    sessionNum = sessionNum + 1;
end


%clear workspace
clc; 
clear all;

addpath('PTB-Game-Engine/GameEngine');     %game engine
addpath('Common');                         %files used by all the games (main, lickspout only, and joystick only)
addpath('Main Game');                      %joystick uses some of the main game files
addpath('Joystick Only');
addpath('Img');                            %image files

requestInput;%get rig specific data from user via GUI
developerMode = isfile('devMode.ignore');%this allows devmode to be set independent of rig, and ignored by git requests

%if we are in developer mode, give user the option to use keyboard as input
if developerMode
choice = menu('Keyboard or Autobehavior Rig input?','Keyboard','Rig');
usingKeyboard = choice==1;
else
usingKeyboard = false;
end


if usingKeyboard
    io = Keyboard;
else
    choice = menu('Which circuit board are you using?', 'Gen2 (Purple)','Gen4','Gen2.1 (Gen3 hardware on purple PCB)');
    switch choice
        case 1
            io = HardwareIOGen2(port);
        case 2
            io = HardwareIOGen4(port);
        case 3
            io = HardwareIOGen2_1(port);
    end
end

emailer = Emailer('sender','recipients',developerMode);%doesn't send mail if we are in dev mode
renderer = Renderer(screenNum,0.5);%(screenNumber,default background color)
grating = JoystickGratedCircle;
greenCirc = TargetRing;
grating.RenderAfter(greenCirc);%make grating render behind green circle
iescape = EscapeQuit;%object that makes game quit if you press the escape key
sound = SoundMaker;

controller = GratedCircleController(grating,io);

%manager handles game logic. Constructor params are references to objects
%that it interacts with
manager = JoystickGameManager(grating,greenCirc,[],controller,io,sound,[]);
manager.SetMaxTrials(numTrials);
manager.SetAllowIncorrect(reward);


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
    msg = char(getReport(e,'extended','hyperlinks','off'));
    subject = "Autobehaviour ERROR: rig "+string(rig)+" mouse "+string(mouseID);
    emailer.Send(subject,msg);
    rethrow(e);
end
if manager.GetNumberOfGamesPlayed()>=numTrials
    msg = char("mouse "+string(mouseID) + " on rig " + string(rig) + " has successfully completed " + string(numTrials) + " trials.");
    subject = "Autobehaviour SUCCESS: rig "+string(rig)+" mouse "+string(mouseID);
    emailer.Send(subject,msg);
end

clc; 
clear all;

requestInput();
addpath('Common');
addpath('PTB-Game-Engine/GameEngine');

results = Results(mouseID,numTrials,sessionNum,'closedLoopTraining',natBackground);
results.setSaveDirectory(saveDir);

time1 = GetSecs();
pause(4);
time2 = GetSecs();
disp(time2-time1); %returns 4.0006

% results.StartTrial(0,0,GetSecs());
% 
% results.LogLick(GetSecs());
% 
% results.EndTrial(GetSecs());
% 
% results.StartTrial(0, 0, GetSecs());
% results.EndTrial(GetSecs());
% 
% results.StartTrial(0, 0, GetSecs());
% results.EndTrial(GetSecs());
% results.StartTrial(0, 0, GetSecs());
% results.EndTrial(GetSecs());
% 
% results.save();
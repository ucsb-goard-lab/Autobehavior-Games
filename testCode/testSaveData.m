clc; 
clear all;

requestInput();
addpath('Common');
addpath('PTB-Game-Engine/GameEngine');

results = Results(mouseID,numTrials,sessionNum,'closedLoopTraining',natBackground);
results.setSaveDirectory(saveDir);

results.StartTrial(0,0,GetSecs());

results.LogLick(GetSecs());

results.EndTrial(GetSecs());

results.StartTrial(0, 0, GetSecs());
results.EndTrial(GetSecs());

results.StartTrial(0, 0, GetSecs());
results.EndTrial(GetSecs());
results.StartTrial(0, 0, GetSecs());
results.EndTrial(GetSecs());

results.save();
classdef Results < handle
    %RESULTS results from a series of trials
    %for stimulusposition and joystickresponses:
    %    -1 : left
    %     0 : no choice
    %     1 : right
    properties (Constant)
        FRAMES_PER_TRIAL = 1800;
    end
    properties (Access = public)
        filename
        mouseID
        sessionNum
        sessionID
        saveDir
        csvFilename
        startTimes
        endTimes
        contrastSequence
        contrastOptions
        stimSequence
        joystickResponses
        joystickResponseTimes
        joystickCounts
        responseCorrect
        responded
        firstLickTimes
        numTrials
        trialType
        currentTrial
        currentFrame
        frames
        lastSavedFrame
        saveDir2
        globalStart
        naturalisticBackground
    end
    
    methods
        function obj = Results(id, trials, sessionNum,type, naturalisticBackground)
            
            %empty buffers for data logging
            obj.naturalisticBackground = naturalisticBackground;
            obj.startTimes = zeros(1,trials);
            obj.stimSequence = zeros(1,trials);
            obj.lastSavedFrame = 0;
            obj.contrastSequence = zeros(1,trials);
            obj.joystickResponses = zeros(1,trials);
            obj.joystickResponseTimes = -1*ones(1,trials);%-1 is used as a null value
            obj.joystickCounts = zeros(1,trials);
            obj.responseCorrect = zeros(1,trials);
            obj.responded = zeros(1,trials);
            obj.firstLickTimes = [];
            obj.numTrials = trials;
            obj.trialType = type;
            obj.mouseID = id;
            obj.sessionNum = sessionNum;
            obj.currentTrial = 0;
            %save directory
            obj.sessionID = [datestr(date, 'mmddyy') '_' num2str(obj.sessionNum)];
            
        end
        function obj = setSaveDirectory(obj,primaryDirectory,secondaryDirectory)
            if nargin<3
                secondaryDirectory = primaryDirectory;
            end
            %sets save directory for data. optional parameter 
            %secondary directory is for using a networked drive to save data.
            %if the networked drive is unavailable, data will be saved to secondary
            fileName = [obj.mouseID, '_', obj.sessionID];
            obj.saveDir = [primaryDirectory,'/',fileName];
            obj.saveDir2 = [secondaryDirectory,'/',fileName];
            %obj.saveDir = strcat('Z:/Autobehavior Data/', obj.mouseID, '_', obj.sessionID);
            %obj.saveDir2 = strcat('C:/Autobehavior Data/', obj.mouseID, '_', obj.sessionID);
            try
                mkdir(obj.saveDir);
            catch
                mkdir(obj.saveDir2);
                obj.saveDir = obj.saveDir2;
            end
            obj.csvFilename = strcat(obj.saveDir, '/', obj.mouseID, '_', obj.sessionID,'_Frames', '.csv');
            csvHeaders = {'Encoder Reading', 'Lickometer', 'Timestamp'};
            csvfid = fopen(obj.csvFilename, 'w') ;
            fprintf(csvfid, '%s,', csvHeaders{1,1:end-1}) ;
            fprintf(csvfid, '%s\n', csvHeaders{1,end}) ;
            fclose(csvfid);
        end
        function [] = StartTrial(obj, stimulusPosition, contrastSeq, startTime)
            obj.currentTrial = obj.currentTrial + 1;
            if obj.currentTrial<=1
                c = clock;
                obj.globalStart = [c(3),c(4)];
            end
            trialNum = obj.currentTrial;
            obj.stimSequence(trialNum) = stimulusPosition;
            obj.contrastSequence(trialNum) = contrastSeq;
            obj.startTimes(trialNum) = startTime;
            obj.frames = zeros(obj.FRAMES_PER_TRIAL,3);
            obj.currentFrame = 0;
        end
        function [] = setContrastOptions(obj,renderer)  % ???
            obj.contrastOptions = renderer.CONTRAST_OPTIONS;
        end
        function [] = cancelTrial(obj)
            obj.currentTrial = obj.currentTrial-1;
        end
        function [] = LogHit(obj,side)
            obj.responseCorrect(obj.currentTrial) = 0;
            obj.joystickResponses(obj.currentTrial) = side;
            obj.responded(obj.currentTrial) = 1;%true
        end
        function [] = LogFrame(obj,encoder,lickMeter,time)
            obj.currentFrame = obj.currentFrame+1;
            obj.frames(obj.currentFrame,1) = encoder;
            obj.frames(obj.currentFrame,2) = lickMeter;
            obj.frames(obj.currentFrame,3) = time;
        end
        
        function [] = LogSuccess(obj, time)
            if ~obj.responded(obj.currentTrial)
                obj.responseCorrect(obj.currentTrial) = 1;
                obj.joystickResponses(obj.currentTrial) = -obj.stimSequence(obj.currentTrial);
                obj.responded(obj.currentTrial) = 1;%true
            end
            obj.joystickResponseTimes(obj.currentTrial) = time-obj.startTimes(obj.currentTrial);
        end
        function [] = LogLick(obj, time)
            obj.firstLickTimes(obj.currentTrial) = time;
        end
        function [] = LogJoy(obj,reading,side,time)
            obj.joystickResponses(obj.currentTrial) = side;
            obj.joystickCounts(obj.currentTrial) = reading;
            obj.joystickResponseTimes(obj.currentTrial) = time;
        end
        function [] = EndTrial(obj,time)
            obj.endTimes(obj.currentTrial) = time;
        end

        %save results in '.mat' file
        function [] = save(obj,secondTry)
            if nargin<2
                secondTry = false;
            end
            try
                save([obj.saveDir '/' obj.mouseID '_' obj.sessionID '_ ' obj.trialType '_results.mat'],'obj');
                for i = (obj.lastSavedFrame+1):obj.currentFrame
                     dlmwrite(obj.csvFilename,obj.frames(i,:),'delimiter',',','precision',9,'-append');
                end
                obj.lastSavedFrame = obj.currentFrame;
            catch e
                if ~secondTry
                    obj.saveDir = obj.saveDir2;
                    warning('Lost connection to Z drive server');
                    obj.save(true);
                else
                    rethrow(e);
                end
            end
        end
     
        
        %overall correct rate (including no-response trials)
        function ocr = getOverallCorrectRate(obj)
            ocr = mean(obj.responseCorrect(1:obj.currentTrial));
        end
        
        %overall response rate
        function orr = getOverallResponseRate(obj)
            orr = mean(obj.responded(1:obj.currentTrial));
        end
        
        %correct rate for trials with 'Left' stimulus
        function out = getCorrectRate(obj,direction)
            out = obj.meanOfMatching(obj.stimSequence,direction,obj.responseCorrect);
        end
        function out = meanOfMatching(obj,arrayToMatch,direction,arrayOfValues)
             responses = zeros(1,obj.currentTrial);
            n = 0;
            for i = 1:obj.currentTrial
                if arrayToMatch(i) == direction     
                    n = n+1;
                    responses(n) = arrayOfValues(i);
                end
            end
            if n==0
                out = 0;
                return;
            end
            out = sum(responses(1:n))/n;
        end
        
   
        
        %response rate for trials with 'Left' stimulus
        function out = getResponseRate(obj,direction)
            out = obj.meanOfMatching(obj.stimSequence,direction,obj.responded);
        end
        
        
        %fraction of time mouse response to the left (doesn't include no-response trials)
        function out = getResponseProportion(obj,direction)
            responses = obj.joystickResponses(obj.responded==1);
            out = sum(responses==direction)/numel(responses);
        end
        
        %correct rate for a specific contrast level
        function out = getCorrectRateForContrast(obj, cont)
            out = obj.meanOfMatching(obj.contrastSequence,cont,obj.responseCorrect);
        end
        
        %response rate for a specific contrast level
        function out = getResponseRateForContrast(obj, cont)
            out = obj.meanOfMatching(obj.contrastSequence,cont,obj.responded);
        end
        
        %print out all of the information
        function [] = printStats(obj)
            fprintf('Overall correct rate = %f\n', obj.getOverallCorrectRate());
            fprintf('Overall response rate = %f\n', obj.getOverallResponseRate());
            fprintf('Left corect rate = %f\n', obj.getCorrectRate(-1));
            fprintf('Right correct rate = %f\n', obj.getCorrectRate(1));
            fprintf('Left response rate = %f\n',  obj.getResponseRate(-1));
            fprintf('Right response rate = %f\n', obj.getResponseRate(1));
            fprintf('Left response proportion = %f\n', obj.getResponseProportion(-1));
            fprintf('Right response proportion = %f\n', obj.getResponseProportion(1));
            for c = obj.contrastOptions
                disp(['Correct rate for contrast=' num2str(c) ': ' num2str(obj.getCorrectRateForContrast(c))]);
                disp(['Response rate for contrast=' num2str(c) ': ' num2str(obj.getResponseRateForContrast(c))]);
            end
        end
        function [] = shortStats(obj)
            fprintf(int2str(obj.currentTrial) + " games played\n");
            fprintf("Success Rate : %d %%\n",floor(obj.getOverallCorrectRate()*100));
            obj.horizontalLine();
            fprintf("Mouse makes a choice %d %% of the time. \n",floor(obj.getOverallResponseRate()*100));
            fprintf("Mouse chooses left %d %% of the time. \n",floor(obj.getResponseProportion(-1)*100));
            obj.horizontalLine();
            fprintf("On average, the mouse chooses the same direction %.2f times in a row\n",obj.avgStreak());
        end
        function [] = horizontalLine(obj)
            fprintf("---------------------------------\n\n");
        end
        function out = getCurrentTrial(obj)
            out = obj.currentTrial;
        end
        
        %get fraction of left responses of a specific interval of trials. Used for bias correction
        function out = getLeftProportionOnInterval(obj,num)
            didRespond = obj.responded(1:obj.currentTrial);
            allResponses = obj.joystickResponses(1:obj.currentTrial);
            responses = allResponses(logical(didRespond));
            if numel(responses)==0
                out = 0.5;
                return;
            end
            start = max((numel(responses)-num),1);
            interval = responses(start:end);
            out = sum(interval==-1)/numel(interval);
        end
        
        function out = avgStreak(obj)
            responses = obj.joystickResponses(1:obj.currentTrial);
            actualResponses = responses(responses~=0);
            directionChanges = zeros(1,numel(actualResponses));
            directionChanges(1) = 1;
            for i = 2:numel(actualResponses)
                if actualResponses(i)~=actualResponses(i-1)
                    directionChanges(i) = 1;
                end
            end
            out = numel(actualResponses)/sum(directionChanges);
        end
    end
    
end


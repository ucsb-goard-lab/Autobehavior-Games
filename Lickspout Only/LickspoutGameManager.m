classdef LickspoutGameManager < GameObject
    properties (Constant)
        waterGiveTime = 0.06;
    end
    properties (Access = protected)
        ioDevice
        soundMaker
        wasLicking
    end
    methods (Access = public)
        function obj = LickspoutGameManager(ioDevice,soundMaker)
            obj.ioDevice = ioDevice;
            obj.soundMaker = soundMaker;
        end
        function obj = Awake(obj)
            obj.wasLicking = true;
        end
        function obj = Update(obj)
            if obj.ioDevice.ReadLick() %if spout and tube are shorted
                if ~obj.wasLicking %and mouse was not licking before
                    clc;
                    disp('LICK DETECTED');
                end
                obj.wasLicking = true;
                obj.ioDevice.GiveWater(obj.waterGiveTime);
                obj.soundMaker.RewardNoise();
            else
                if obj.wasLicking
                    clc;
                    disp('Waiting for lick...');
                end
                obj.wasLicking = false;
            end
        end
    end
end
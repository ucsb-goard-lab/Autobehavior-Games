classdef SoundMaker < handle
properties (Constant)
    TONE_SAMPLE_FREQUENCY = 12000
    REWARD_TONE_DURATION = .25
    REWARD_TONE_FREQUENCY = 10000
    NOISE_TONE_DURATION = .5
end
    
properties(Access = private)
    rewardTone
    noiseTone
end
methods(Access = public)
    function obj = SoundMaker()
        obj.rewardTone = obj.MakeTone(obj.REWARD_TONE_DURATION, obj.REWARD_TONE_FREQUENCY, obj.TONE_SAMPLE_FREQUENCY);
        obj.noiseTone = rand(1,floor(0.5*obj.TONE_SAMPLE_FREQUENCY)) - 0.5;
    end
    function obj = BadNoise(obj)
        sound(obj.noiseTone, obj.TONE_SAMPLE_FREQUENCY);
    end
    function obj = RewardNoise(obj)
         sound(obj.rewardTone,obj.TONE_SAMPLE_FREQUENCY);
    end
    function tone = MakeTone(obj,duration,freq,fs)
        t=0:1/fs:duration-1/fs;
        tone = cos(2*pi* freq*t)*.3;
    end
end


end
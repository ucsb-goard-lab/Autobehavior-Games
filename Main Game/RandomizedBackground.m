classdef RandomizedBackground < Renderable
    properties(Constant)
        radius = 100;
    end
    properties(Access = private)
        quantity;
        imageMatrix;
        range;
    end
    methods(Access = public)
        function obj = RandomizedBackground(imgFileName,quantity, range)
            %range defines [x range, y range] where each element is the
            %percent of the screen (x and y) that can be filled by the
            %instances
            if nargin<3
                range = [1,1];
            end
            obj.range = range;
            obj.quantity = quantity;
            obj.imageMatrix = obj.PngToImg(imgFileName);
            obj.screenBounded = false;
        end
        function obj = Awake(obj)
            sizeVector = ones(1,2)* 2*obj.radius;
            pos = [0,0];
            for i = 1:obj.quantity
                obj.InstantiateNew(pos,sizeVector);
            end
            obj.RandomizePositions;
        end
        function obj = RandomizePositions(obj)
            for i = 1:size(obj.position,1)
                obj.position(i,:) = obj.GenerateRandomPosition(i);
            end
        end
        function out = GenerateRandomPosition(obj,instance)
            windowSize = obj.Renderer.WindowSize();
            out = (rand(1,2)-0.5).*windowSize.*obj.range;
            for i = 1:2
                if abs(out(i))<2*obj.radius
                    out = obj.GenerateRandomPosition(instance);
                    return;
                end
            end
            for i = 1:size(obj.position,1)
                dist = sum(sqrt((out-obj.position(i,:)).^2));
                if i~=instance && ((dist<2*obj.radius))
                    out = obj.GenerateRandomPosition(instance);
                end
            end
        end
        function img = GenerateImage(obj)
            img = obj.imageMatrix;
        end
    end
end

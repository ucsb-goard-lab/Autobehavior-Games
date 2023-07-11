classdef AnimatedGratedCircle < GratedCircle
    properties(Access = protected)
        image_bank
        frame_ct = 0
        frame_change
    end
    methods(Access = public)
        function obj = AnimatedGratedCircle(opacityPool, image_bank, frame_change)
            if nargin < 3 || isempty(frame_change)
                frame_change = 1;
            end
            obj = obj@GratedCircle(opacityPool);
            obj.image_bank = image_bank;
            obj.frame_change = frame_change;
        end

        function img = GenerateImage(obj) 
            img = obj.PngToImg('grating.png'); %uncomment this line
            imgs = dir(strcat(obj.image_bank, '/*.png'));
            for im = 1:length(imgs)
                img(:, :, :, im) = obj.PngToImg([imgs(im).folder, '/', imgs(im).name]);
            end
        end

        function obj = SendImage(obj)
            for im = 1:size(obj.image, 4)
                obj.texture(im) = obj.Renderer.ImageToTexture(obj.image(:, :, :, im));
            end
        end

        function [positions,tex,alpha] = GetData(obj)
            img_to_use = mod(floor(obj.frame_ct/obj.frame_change), size(obj.image, 4)) + 1;

            globalPos = obj.Renderer.Center()+obj.GetGlobalPosition();
            positions = [obj.position(:,1)-obj.size(:,1)/2 ,obj.position(:,2)-obj.size(:,2)/2,obj.position(:,1)+obj.size(:,1)/2,obj.position(:,2)+obj.size(:,2)/2];
            positions = positions + [globalPos,globalPos];
            tex = obj.texture(img_to_use);
            alpha = obj.globalAlpha;

            obj.frame_ct = obj.frame_ct + 1;
        end


    end
end

classdef TargetRing < Renderable
    properties(Constant)
        radius = 100/0.75;
        innerRadius = 100;
    end
    methods(Access = public)
        function obj = TargetRing()
            obj.size = ones(1,2)*2*obj.radius;
            obj.renderLayer = 0;
        end
        function img = GenerateImage(obj)
            side = floor(obj.radius)*2;
            [x,y]=meshgrid(1:side, 1:side);
            circleMask = (((x - side/2).^2 + (y - side/2).^2)<=obj.radius^2) & (((x - side/2).^2 + (y - side/2).^2)>obj.innerRadius^2);
            ring = ones(side,side,4);
            ring(:,:,1) = 0;
            ring(:,:,2) = 1;
            ring(:,:,3) = 0;
            ring(:,:,4) = circleMask;
            img = ring;  
        end
    end
end

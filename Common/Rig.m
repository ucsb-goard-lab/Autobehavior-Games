classdef Rig < IODevice
    properties(Constant)
        joystickResponseThreshold = 0.2;
        maxJoystickValue = 100
        servoAdjustmentTime = 0.5;
        evaporationConstant = .15/3600;
        readAttemptsBeforeFailure = 100;
        minServoPulse = 0.001;
        maxServoPulse = 0.002;
    end
     properties(Access = protected)
        leftServoOpenPos = 0.4
        rightServoOpenPos = 0.6
        leftServoClosedPos = 0
        rightServoClosedPos = 1
        port
        arduinoBoard
        leftServo
        rightServo
        encoder
        digitalOutputPins
        digitalInputPins
        analogInputPins
        pullupPins
        lastWaterTime
     end
        methods (Access = public)
        function out = ReadJoystick(obj)
             out = obj.TryOrRebuild('UnsafeReadJoystick');
        end
        function out = UnsafeReadJoystick(obj)
        end
        function out = ReadIR(obj)
            out = obj.TryOrRebuild('UnsafeReadIR');
        end
        function out = UnsafeReadIR(obj)
        end
        function obj = PositionServos(obj,left,right)
            try
                obj.UnsafePositionServos(left,right);
            catch e
                obj.RefreshBoard();
                obj.UnsafePositionServos(left,right);
            end
        end
        function obj = CloseServos(obj)
            %obj.PositionServos(obj.leftServoClosedPos,obj.rightServoClosedPos);

            %added smooth close function
            obj. SmoothCloseServos();
            obj.DelayedCall('ResetEnc',obj.servoAdjustmentTime);
        end

        function PrintServoTargets(obj)
            disp(obj.leftServoOpenPos);
            disp(obj.leftServoClosedPos);
            disp(obj.rightServoOpenPos); 
            disp(obj.rightServoClosedPos);
        end

        function obj = OpenServos(obj)
            
            %obj.PositionServos(obj.leftServoOpenPos,obj.rightServoOpenPos);
            %added smooth open function
            obj.SmoothOpenServos();
        end

        function obj = SmoothOpenServos(obj)
			obj.PowerServos(true);
            %plot 10 points between 10 and 100, rescale to between 0 and 1
			smooth = rescale(logspace(1, 2, 10));
			leftPositions = obj.leftServoClosedPos + (obj.leftServoOpenPos - obj.leftServoClosedPos) * smooth;
			rightPositions = obj.rightServoClosedPos + (obj.rightServoOpenPos - obj.rightServoClosedPos) * smooth;
			for ii = 1:10
				obj.leftServo.writePosition(leftPositions(ii));
				obj.rightServo.writePosition(rightPositions(ii));
			end
			obj.DelayedCall('PowerServos', obj.servoAdjustmentTime, false);
        end

        function obj = SmoothCloseServos(obj)
			obj.PowerServos(true);
			smooth = rescale(logspace(1, 2, 10));
			leftPositions = obj.leftServoOpenPos + (obj.leftServoClosedPos - obj.leftServoOpenPos) * smooth;
			rightPositions = obj.rightServoOpenPos + (obj.rightServoClosedPos - obj.rightServoOpenPos) * smooth;
			for ii = 1:10
				obj.leftServo.writePosition(leftPositions(ii));
				obj.rightServo.writePosition(rightPositions(ii));
			end
			obj.DelayedCall('PowerServos', obj.servoAdjustmentTime, false);
		end

        function obj = OpenSide(obj,side)
            if side<0
                obj.PositionServos(obj.leftServoOpenPos,obj.rightServoClosedPos);
            else
                obj.PositionServos(obj.leftServoClosedPos,obj.rightServoOpenPos);
            end
        end
        function obj = UnsafePositionServos(obj,left,right)
            if isempty(obj.leftServo) || isempty(obj.rightServo)
                warning('Servos have not been initialized. Call ignored.');
                return;
            end
            obj.leftServo.writePosition(left);
            obj.rightServo.writePosition(right);
        end
        function obj = ResetEnc(obj,value)
            if nargin<2
                value = 0;
            end
           resetCount(obj.encoder,value);
        end
        function obj = ConfigurePins(obj)
            pinGroups = {obj.digitalOutputPins,obj.digitalInputPins,obj.analogInputPins,obj.pullupPins};
            types = {'DigitalOutput','DigitalInput','AnalogInput','pullup'};
            for i = 1:numel(pinGroups)
                type = types{i};
                for pin = pinGroups{i}
                    configurePin(obj.arduinoBoard,pin,type);
                end
            end
        end
        function obj = CloseSolenoid(obj)
        end
        function obj = OnQuit(obj)
            obj.TurnOffEverything();
        end
        function obj = OnError(obj)
            obj.TurnOffEverything();
        end
        function obj = TurnOffEverything(obj)
            obj.CloseSolenoid();
            obj.CloseServos();
        end
        function out = Try(obj,methodName)
            i = 0;
            while i < obj.readAttemptsBeforeFailure
                i = i+1;
                try
                    out = obj.(methodName);
                    if i>1
                        warning(string(methodName)+" took "+i+" attempts to resolve!");
                    end
                    return;
                catch e
                end
            end
            rethrow(e);
        end
        function out = TryOrRebuild(obj,methodName)
            try
                out = obj.Try(methodName);
            catch e
                clc;
                obj.Renderer.ClearFrame();
                c = clock;
                warning(e.message);
                fprintf("System is currently trying to reconnect to arduino.\n");
                fprintf("Disconnected since "+  c(4)+":"+c(3)+", "+c(2)+"/"+c(3)+"/"+c(1)+"\n");
                obj.RefreshBoard();
                fprintf("Arduino has successfully reconnected!\n");
                out = obj.Try(methodName);
            end
        end
        function obj = RefreshBoard(obj)
            obj.arduinoBoard = [];
            obj.leftServo = [];
            obj.rightServo = [];
            obj.encoder = [];
            obj.Awake();
        end
    end
end
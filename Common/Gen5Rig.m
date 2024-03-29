classdef  Gen5Rig < IODevice
	properties(Constant)
		%pins
		leftServoPin = "D10"
		rightServoPin = "D9"
		servoPowerPin = "D6"
		encoderPinA = "D2"
		encoderPinB = "D3"
		solenoidPin = "D8"
		lickmeterReadPin  = "A2"
		breakBeamPin = "D7"


		lickVoltageDelta = 1;%expected change in voltage on lickmeter when mouse licks
		lickNominalVoltage = 5;%expected voltage from the lickmeter
		servoAdjustmentTime = 0.75;%expected time it takes the servos to move
		evaporationConstant = .15/3600;%how much water evaporates per time. (unknown units calculated by james)
		maxJoystickValue = 50;%max expected change in joystick reading
		joystickResponseThreshold = 0.1;%ratio of max at which we return a value. this gives the joystick a deadzone

		%servo positions in degrees
		leftServoOpenPos = 100;
		rightServoOpenPos = 170;
		leftServoClosedPos = 180;
		rightServoClosedPos = 90; 
	end

	properties(Access = protected)
		arduino;
		lastWaterTime;
	end

	methods (Access = public)

		function obj = Gen5Rig(port)
			obj.arduino = Arduino(port);
		end

		function obj = Awake(obj)          
			obj.arduino.connect();  
			obj.ConfigurePins();            
			obj.arduino.encoder(obj.encoderPinA,obj.encoderPinB);
			obj.arduino.attachServo(obj.leftServoPin);
			obj.arduino.attachServo(obj.rightServoPin);
			obj.CloseServos();  

% awake function ctrl c + ctrl v from hardwareiogen5
%             obj.arduinoBoard = arduino(obj.port,'uno','libraries',{'servo','rotaryEncoder'});
%             obj.ConfigurePins();            
%             obj.encoder = rotaryEncoder(obj.arduinoBoard, obj.encoderPinA,obj.encoderPinB);
%             
%             obj.leftServo = servo(obj.arduinoBoard,obj.leftServoPin,'MinPulseDuration',obj.minServoPulse,'MaxPulseDuration',obj.maxServoPulse);
%             obj.rightServo = servo(obj.arduinoBoard,obj.rightServoPin,'MinPulseDuration',obj.minServoPulse,'MaxPulseDuration',obj.maxServoPulse);
%              obj.CloseServos();
		end

		function out = ReadJoystick(obj)

			reading = -obj.arduino.readEncoder(obj.encoderPinA);
			out = reading/obj.maxJoystickValue;
			if abs(out) >obj.maxJoystickValue
				out = 1;
			end

			if abs(out)<obj.joystickResponseThreshold
				out = 0;
			end 
			out = out - (sign(out)*obj.joystickResponseThreshold);
			out = out /(1-obj.joystickResponseThreshold);
		end

		function out = ReadIR(obj)         
			out = ~obj.arduino.digitalRead(obj.breakBeamPin);
		end

		function out = ReadLick(obj)
			val = obj.arduino.analogRead(obj.lickmeterReadPin);
			out = abs(val-obj.lickNominalVoltage)>obj.lickVoltageDelta;
		end

		function obj = GiveWater(obj,time)
			obj.arduino.digitalWrite(obj.solenoidPin,1);
			if obj.lastWaterTime>0
				time = time + obj.evaporationConstant*(obj.Game.GetTime() - obj.lastWaterTime)*2;
			end
			obj.lastWaterTime = obj.Game.GetTime();
			obj.DelayedCall('CloseSolenoid',time);
		end

		function obj = CloseSolenoid(obj)
			obj.arduino.digitalWrite(obj.solenoidPin,0);
		end

		function obj = CloseServos(obj)
% 			obj.PositionServos(obj.leftServoClosedPos,obj.rightServoClosedPos);
			obj.SmoothCloseServos();
			obj.DelayedCall('ResetEncoder',obj.servoAdjustmentTime);
		end
		function obj = ResetEncoder(obj)
			obj.arduino.resetEncoder(obj.encoderPinA);
		end

		function obj = OpenServos(obj)
% 			obj.PositionServos(obj.leftServoOpenPos,obj.rightServoOpenPos);
			obj.SmoothOpenServos();
		end

		function obj = OpenSide(obj,side)
			if side<0
				obj.PositionServos(obj.leftServoOpenPos,obj.rightServoClosedPos);
			else
				obj.PositionServos(obj.leftServoClosedPos,obj.rightServoOpenPos);
			end
		end

		function obj = SmoothOpenServos(obj)
			obj.PowerServos(true);
            %plot 10 points between 10 and 100, rescale to between 0 and 1
			smooth = rescale(logspace(1, 2, 10));
			leftPositions = obj.leftServoClosedPos + (obj.leftServoOpenPos - obj.leftServoClosedPos) * smooth;
			rightPositions = obj.rightServoClosedPos + (obj.rightServoOpenPos - obj.rightServoClosedPos) * smooth;
			for ii = 1:10
				obj.arduino.writeServo(obj.leftServoPin, leftPositions(ii));
				obj.arduino.writeServo(obj.rightServoPin, rightPositions(ii));
			end
			obj.DelayedCall('PowerServos', obj.servoAdjustmentTime, false);
		end

		function obj = SmoothCloseServos(obj)
			obj.PowerServos(true);
			smooth = rescale(logspace(1, 2, 10));
			leftPositions = obj.leftServoOpenPos + (obj.leftServoClosedPos - obj.leftServoOpenPos) * smooth;
			rightPositions = obj.rightServoOpenPos + (obj.rightServoClosedPos - obj.rightServoOpenPos) * smooth;
			for ii = 1:10
				obj.arduino.writeServo(obj.leftServoPin, leftPositions(ii));
				obj.arduino.writeServo(obj.rightServoPin, rightPositions(ii));
			end
			obj.DelayedCall('PowerServos', obj.servoAdjustmentTime, false);
		end

		function obj = PositionServos(obj,left,right)
			obj.PowerServos(true);
			obj.arduino.writeServo(obj.leftServoPin,left);
			obj.arduino.writeServo(obj.rightServoPin,right);
			obj.DelayedCall('PowerServos',obj.servoAdjustmentTime,false);
		end

		function obj = PowerServos(obj,state)
			obj.arduino.digitalWrite(obj.servoPowerPin,state);
		end

		function obj = TurnOffEverything(obj)
			obj.CloseSolenoid();
			obj.arduino.detachServo(obj.leftServoPin);
			obj.arduino.detachServo(obj.rightServoPin);
			obj.arduino.detachEncoder(obj.encoderPinA);
			obj.PowerServos(false);
		end
		function obj = ConfigurePins(obj)
			outputPins = [obj.solenoidPin, obj.servoPowerPin];
			inputPins = [obj.lickmeterReadPin];
			pullupPins = [obj.breakBeamPin];
			pinGroups = {outputPins,inputPins,pullupPins};
			types = ["OUTPUT","INPUT","INPUT_PULLUP"];
			for i = 1:numel(pinGroups)
				type = types(i);
				for pin = pinGroups{i}
					obj.arduino.pinMode(pin,type);
				end
			end
		end
		function obj = OnQuit(obj)
			obj.TurnOffEverything();
			obj.arduino.clearPort();
		end
		function obj = OnError(obj)
			obj.TurnOffEverything();
			obj.arduino.clearPort();
		end

	end
end

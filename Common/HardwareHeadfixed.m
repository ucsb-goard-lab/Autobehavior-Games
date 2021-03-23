classdef HardwareHeadfixed < Rig
        properties(Constant)
        leftServoPin = "D11"
        rightServoPin = "D10"
        encoderPinA = "D3"
        encoderPinB = "D2"
        solenoidPin = "A1"
        lickmeterReadPin  = "A5"
        lickmeterPowerPin = "A4"
        
        
        %table of servo open positions
        %rig number | right open position | left open position
        servoPositionTable = [...
            0,0.6,0.4;...
            1,0.6,0.3;...
            2,0.65,0.3;...
            3,0.65,0.5;...
            4,0.65,0.35;...
            5,0.6,0.4;...
            6,0.6,0.4;...
            10,0.65,0.4;...
            20,0.6,0.4]
        end
    methods (Access = public)
        function obj = HardwareHeadfixed(port,rigNum)
            obj.port = port;
            [obj.leftServoOpenPos,obj.rightServoOpenPos] = obj.getServoPositions(rigNum);
            obj.digitalOutputPins = [obj.solenoidPin,obj.lickmeterPowerPin];
            obj.digitalInputPins = [];
            obj.analogInputPins = [obj.lickmeterReadPin];
            obj.pullupPins = [];
           obj.leftServoClosedPos = 0;
            obj.rightServoClosedPos = 1;
        end
         function obj = Awake(obj)          
            obj.arduinoBoard = arduino(obj.port,'uno','libraries',{'servo','rotaryEncoder'});
            obj.ConfigurePins();            
            
            obj.encoder = rotaryEncoder(obj.arduinoBoard, obj.encoderPinA,obj.encoderPinB);
            
            obj.leftServo = servo(obj.arduinoBoard,obj.leftServoPin,'MinPulseDuration',obj.minServoPulse,'MaxPulseDuration',obj.maxServoPulse);
            obj.rightServo = servo(obj.arduinoBoard,obj.rightServoPin,'MinPulseDuration',obj.minServoPulse,'MaxPulseDuration',obj.maxServoPulse);
            obj.CloseServos();
        end
         function out = UnsafeReadJoystick(obj)
            out = readCount(obj.encoder)/obj.maxJoystickValue;
            if abs(out)>1
                out = sign(out);
                obj.ResetEnc(out*obj.maxJoystickValue);
                return;
            end
            if abs(out)<obj.joystickResponseThreshold
                out = 0;
                return;
            end 
         end
        function out = ReadIR(obj)
            out = true;
        end
        function out = ReadLick(obj)
            val = readVoltage(obj.arduinoBoard,obj.lickmeterReadPin);
            out = abs(val-obj.lickNominalVoltage)>obj.lickVoltageDelta;
        end
        function obj = GiveWater(obj,time)
             writeDigitalPin(obj.arduinoBoard,obj.solenoidPin,1);
             if obj.lastWaterTime>0
                 time = time + obj.evaporationConstant*(obj.Game.GetTime() - obj.lastWaterTime);
             end
             obj.lastWaterTime = obj.Game.GetTime();
             obj.DelayedCall('CloseSolenoid',time);
        end
        function obj = CloseSolenoid(obj)
            writeDigitalPin(obj.arduinoBoard,obj.solenoidPin,0);
        end

    end
    methods (Access = private)
        function out = tableLookup(obj,table,value)
            for i = 1:numel(table(:,1))
                if table(i,1) == value
                    out = table(i,:);
                    return;
                end
            end
        end
        function [left,right] = getServoPositions(obj,rig)
            entry = obj.tableLookup(obj.servoPositionTable,rig);
            right = entry(2);
            left = entry(3);
        end
    end
end
-- this applicator script utilizes the solve-module in order to apply the angles to the joints

-- constants 
local Arm = workspace.Arm -- arm object, parent of the arm parts and joints
local length0 = 3.486 -- upper-arm length
local length1 = 2.649 -- lower arm length

local HBS = game:GetService("RunService").Heartbeat -- heartbeat runs every tick
local SolveIK = require(game.ReplicatedStorage.Solve)

local SHOULDER_OFFSET = CFrame.new(0,0,0) -- not used in this example
local ELBOW_OFFSET = CFrame.new(0,0,0)


function init()
	for i,v in pairs (Arm:GetChildren()) do
		if(v.Name == "Shoulder") then
			local shoulder2Arm = Instance.new("Weld", Arm.Arm) -- keep the arm attached to something to prevent it falling apart
			shoulder2Arm.Part0 = Arm.Arm ; shoulder2Arm.Part1 = v
			shoulder2Arm.C0 = CFrame.new(0,(Arm.Arm.Size.Y/2)+(v.Size.Y/2),0) -- offsets the weld so the arm is perfectly aligned
		end
	end
end

wait(5) -- allow the game to load before doing anything
while HBS:Wait() do -- loop that runs every heartbeat tick
	local goalPos = workspace.Target.Position -- goal position
--local difference = (Vector2.new(Arm.Shoulder.Position.Y, Arm.Shoulder.Position.Z) - Vector2.new(Arm.Effector.Position.Y, Arm.Effector.Position.Z)).Magnitude
local length2 = (workspace.Arm.Shoulder.Position - workspace.Target.Position).Magnitude -- calculate the distance from the shoulder to the target position (third line of the triangle)
	local shoulderCFrame = Arm.Shoulder.CFrame*SHOULDER_OFFSET
local angleA = math.acos((-length0^2 + length1^2 - length2^2) / (2 * length1 * length2)) -- using the law of cosines we calculate the angles of the shoulder and elbow
local angleB = math.acos((length0^2 + length1^2 - length2^2) / (2 * length0 * length1))


	local upperV3 = Arm.Arm.Size -- size of upper arm (vector3 value)
	local lowerV3 = Arm.LArm.Size -- size of lower arm (vector3 value)
local bPlane,shoulderAngle,elbowAngle = SolveIK(shoulderCFrame, goalPos, upperV3.Y,lowerV3.Y)
	local shoulderAngleCFrame = CFrame.Angles(shoulderAngle, 0, 0)
	local elbowAngleAngleCFrame = CFrame.Angles(elbowAngle, 0, 0)
	Arm.Arm.CFrame = bPlane * shoulderAngleCFrame * CFrame.new(-upperV3 * 0.5) -- apply the rotation to the upper arm
	Arm.LArm.CFrame = Arm.Arm.CFrame * CFrame.new(-upperV3 * 0.5) * elbowAngleAngleCFrame * CFrame.new(-lowerV3 * 0.5) -- apply rotation to lower arm
	
end



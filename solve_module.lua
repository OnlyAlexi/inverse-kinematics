-- this is the solver Module. The "SolveIK" function takes the origin-CFrame (a table containing position and rotation data of an object)
-- the target-position, the length of the upper arm, the length of the lower arm and returns the base-plane, the desired shoulder angle and the desired elbow angle
local function solveIK(originCF, targetPos, l1, l2)	
	-- build intial values for solving
	print(type(originCF))
	local localized = originCF:pointToObjectSpace(targetPos)
	local localizedUnit = localized.unit
	local l3 = localized.magnitude

	-- build a "rolled" planeCF for a more natural arm look
	local axis = Vector3.new(0, 0, -1):Cross(localizedUnit)
	local angle = math.acos(-localizedUnit.Z)
	local planeCF = originCF * CFrame.fromAxisAngle(axis, angle)

	-- case: point is to close, unreachable
	-- action: push back planeCF so the "hand" still reaches, angles fully compressed
	if l3 < math.max(l2, l1) - math.min(l2, l1) then
		return planeCF * CFrame.new(0, 0,  math.max(l2, l1) - math.min(l2, l1) - l3), -math.pi/2, math.pi

		-- case: point is to far, unreachable
		-- action: for forward planeCF so the "hand" still reaches, angles fully extended
	elseif l3 > l1 + l2 then
		return planeCF * CFrame.new(0, 0, l1 + l2 - l3), math.pi/2, 0

		-- case: point is reachable
		-- action: planeCF is fine, solve the angles of the triangle
	else
		local a1 = -math.acos((-(l2 * l2) + (l1 * l1) + (l3 * l3)) / (2 * l1 * l3))
		local a2 = math.acos(((l2  * l2) - (l1 * l1) + (l3 * l3)) / (2 * l2 * l3))

		return planeCF, a1 + math.pi/2, a2 - a1
	end
end

----

return solveIK

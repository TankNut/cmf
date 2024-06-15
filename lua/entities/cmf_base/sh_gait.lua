AddCSLuaFile()

function ENT:TraceDirection(distance, offset, direction, trace)
	trace = trace or {}

	trace.start = offset
	trace.endpos = offset + direction:GetNormalized() * (distance or 56756)

	if trace.mins then
		return util.TraceHull(trace)
	else
		return util.TraceLine(trace)
	end
end

function ENT:FindGround(pos, origin)
	local maxLength = self.UpperLength + self.LowerLength
	local traceOrigin = Vector(pos)
	traceOrigin.z = self:GetPos().z

	local trace = self:TraceDirection(maxLength * 1.5, traceOrigin, Vector(0, 0, -1), {
		mins = Vector(-5, -5, 0),
		maxs = Vector(5, 5, 0),
		filter = function(ent) return ent != self and ent:GetOwner() != self end
	})

	if not trace.StartSolid and trace.Hit then
		local dist = trace.HitPos:Distance(origin)

		-- NaN check
		if dist < math.abs(self.UpperLength - self.LowerLength - self.FootOffset) then
			return pos, self:GetUp()
		end

		return trace.HitPos, trace.HitNormal
	end

	return pos, self:GetUp()
end

local function remapC(val, inMin, inMax, outMin, outMax)
	val = math.Remap(val, inMin, inMax, outMin, outMax)

	return math.Clamp(val, math.min(outMin, outMax), math.max(outMin, outMax))
end

function ENT:UpdateLegs()
	local entTable = self:GetTable()
	local delta = CurTime() - entTable.LastGaitUpdate

	entTable.LastGaitUpdate = CurTime()

	local height = entTable.GetGroundOffset(self)
	local maxLength = entTable.UpperLength + entTable.LowerLength

	local baseVel = entTable.GetMoveVelocity(self)
	baseVel.z = 0

	local vel = baseVel:Length2D()

	local strideOffset = remapC(baseVel:Dot(self:GetForward()), -530, 530, 0.2, -0.2)
	local liftFraction = math.max(math.Remap(vel, 200, 530, 0.4, 0.6), 0.4)
	local groundFraction = 1 - liftFraction

	local strideAngle = math.asin(height / maxLength)
	local strideLength = (height / math.tan(strideAngle)) * 1.75

	local increase = (vel / strideLength / 4) * (groundFraction * 2)
	local strideVelocity = baseVel:GetNormalized() * math.min(vel, strideLength)

	local fraction = entTable.GetMoveFraction(self)
	local walkCycle = entTable.GetWalkCycle(self) + delta * increase

	for k, leg in pairs(entTable.Legs) do
		local sideOffset = entTable.LegSpacing * leg.Offset

		leg.Cycle = (walkCycle + leg.CycleOffset) % 1

		if fraction < 0.1 then
			leg.Moving = false
		else
			leg.Moving = leg.Cycle > groundFraction
		end

		local origin = self:LocalToWorld(Vector(0, sideOffset, 0))
		local offset = self:LocalToWorld(Vector(strideLength * strideOffset, sideOffset, -height))
		local footPos
		local footNormal = self:GetUp()

		if leg.Moving then
			local cycle = remapC(leg.Cycle, groundFraction, 1, 0, 1)

			local start = entTable.FindGround(self, -strideVelocity + offset, origin)
			local destination = entTable.FindGround(self, strideVelocity + offset, origin)

			local middle = LerpVector(0.5, start, destination)
			middle.z = self:GetPos().z - height * 0.5

			footPos = math.QuadraticBezier(cycle, start, middle, destination)
		else
			local cycle = remapC(leg.Cycle, 0, groundFraction, 0, 1)

			local start = strideVelocity + offset
			local destination = -strideVelocity + offset

			footPos, footNormal = entTable.FindGround(self, LerpVector(cycle, start, destination), origin)
		end

		local idle, idleNormal = entTable.FindGround(self, self:LocalToWorld(Vector(1, sideOffset, -height)), origin)

		footPos = LerpVector(fraction, idle, footPos)
		footNormal = LerpVector(fraction, idleNormal, footNormal)

		leg.Pos = footPos
		leg.Normal = footNormal

		entTable.PerformLegIK(self, k, leg)
	end

	entTable.SetWalkCycle(self, walkCycle % 1)
end

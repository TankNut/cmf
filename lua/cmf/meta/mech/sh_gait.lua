AddCSLuaFile()

local meta = cmf:Class("Mech")

function meta:TraceDirection(distance, offset, direction, trace)
	trace = trace or {}

	trace.start = offset
	trace.endpos = offset + direction:GetNormalized() * (distance or 56756)

	if trace.mins then
		return util.TraceHull(trace)
	else
		return util.TraceLine(trace)
	end
end

local down = Vector(0, 0, -1)
local groundMin = Vector(-5, -5, 0)
local groundMax = Vector(5, 5, 0)

function meta:FindGround(target, origin)
	local pos = self.Position
	local ang = self.Angle

	local maxLength = self.UpperLegLength + self.LowerLegLength
	local traceOrigin = Vector(target)
	traceOrigin.z = pos.z

	local trace = self:TraceDirection(maxLength * 1.5, traceOrigin, down, {
		mins = groundMin,
		maxs = groundMax,
		filter = function(ent) return ent != self.Entity and ent:GetOwner() != self.Entity end
	})

	if not trace.StartSolid and trace.Hit then
		local dist = trace.HitPos:Distance(origin)

		-- NaN check
		if dist < math.abs(self.UpperLegLength - self.LowerLegLength - self.FootOffset) then
			return target, ang:Up()
		end

		return trace.HitPos, trace.HitNormal
	end

	return target, ang:Up()
end

local function remapC(val, inMin, inMax, outMin, outMax)
	val = math.Remap(val, inMin, inMax, outMin, outMax)

	return math.Clamp(val, math.min(outMin, outMax), math.max(outMin, outMax))
end

function meta:GetGroundOffset()
	if self.Entity then
		return self.Entity:GetGroundOffset()
	end

	return self.StandHeight
end

function meta:GetMoveFraction()
	return math.min(self.Velocity:Length2D() / 150, 1)
end

function meta:RunGait()
	local pos = self.Position
	local ang = self.Angle

	local rootBone = self.Bones.root

	rootBone.Position = pos
	rootBone.Angle = ang

	local delta = CurTime() - self.LastGaitUpdate

	self.LastGaitUpdate = CurTime()

	local height = self:GetGroundOffset()
	local maxLength = self.UpperLegLength + self.LowerLegLength

	local baseVel = Vector(self.Velocity)
	baseVel.z = 0

	local vel = baseVel:Length2D()

	local strideOffset = remapC(baseVel:Dot(ang:Forward()), -self.RunSpeed, self.RunSpeed, 0.2, -0.2)
	local liftFraction = remapC(vel, self.WalkSpeed, self.RunSpeed, 0.4, 0.6)
	local groundFraction = 1 - liftFraction

	local strideAngle = math.asin(height / maxLength)
	local strideLength = (height / math.tan(strideAngle)) * 1.75

	local increase = (vel / strideLength / 4) * (groundFraction * 2)
	local strideVelocity = baseVel:GetNormalized() * math.min(vel, strideLength)

	local fraction = self:GetMoveFraction()
	local walkCycle = self.WalkCycle + increase * delta

	for k, leg in pairs(self.Legs) do
		local sideOffset = self.LegSpacing * leg.Offset

		leg.Cycle = (walkCycle + leg.CycleOffset) % 1

		local lastMoving = leg.Moving

		if fraction < 0.1 then
			leg.Moving = false
		else
			leg.Moving = leg.Cycle > groundFraction
		end

		if SERVER and self.Entity and not leg.Moving and leg.Moving != lastMoving then
			self.Entity:EmitSound(")sfx_footfall_generic.wav", 100, math.Rand(95, 105))
		end

		local origin = self:LocalToWorld(Vector(0, sideOffset, 0))
		local offset = self:LocalToWorld(Vector(strideLength * strideOffset, sideOffset, -height))
		local footPos
		local footNormal = ang:Up()

		if leg.Moving then
			local cycle = remapC(leg.Cycle, groundFraction, 1, 0, 1)

			local start = self:FindGround(-strideVelocity + offset, origin)
			local destination = self:FindGround(strideVelocity + offset, origin)

			local middle = LerpVector(0.5, start, destination)
			middle.z = pos.z - height * 0.5

			footPos = math.QuadraticBezier(cycle, start, middle, destination)
		else
			local cycle = remapC(leg.Cycle, 0, groundFraction, 0, 1)

			local start = strideVelocity + offset
			local destination = -strideVelocity + offset

			footPos, footNormal = self:FindGround(LerpVector(cycle, start, destination), origin)
		end

		local idle, idleNormal = self:FindGround(self:LocalToWorld(Vector(1, sideOffset, -height)), origin)

		footPos = LerpVector(fraction, idle, footPos)
		footNormal = LerpVector(fraction, idleNormal, footNormal)

		leg.Pos = footPos
		leg.Normal = footNormal

		self:PerformLegIK(k, leg)
	end

	self.WalkCycle = walkCycle % 1
end

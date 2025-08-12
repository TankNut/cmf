AddCSLuaFile()

-- Look at porting the other gait's 'stance' setup, seems to play nicer with bigger strides (both feet airborne)
local stance = 0.5

function ENT:InitGait()
	self.LastNewGaitUpdate = CurTime()
	self.Gaits = {}

	self.GlobalPos = Vector()
	self.GaitFraction = 0

	self:AddGait(0, Vector(0, 35, 0))
	self:AddGait(0.5, Vector(0, -35, 0))
end

local stepSize = 250

-- Disable gait during physgun move

function ENT:UpdateGait()
	local delta = CurTime() - self.LastNewGaitUpdate
	local vel = self:GetMechVelocity()

	delta = delta * math.max(vel:Length2D() / stepSize, 0.5)

	if vel:Length2D() > (stepSize / 4) then
		vel:Normalize()
		vel:Mul(stepSize / 4)
	end

	self.LastNewGaitUpdate = CurTime()
	self.GlobalPos:Zero()

	self.GaitFraction = (self.GaitFraction + delta) % 1

	local wantsToMove = false

	for k, gait in ipairs(self.Gaits) do
		local gaitFraction = (self.GaitFraction + gait.Timing) % 1

		local offset = self:LocalToWorld(gait.Offset)
		local target = self:NewFindGround(offset + vel, offset)

		-- Check X/Y distance only
		local hasTarget = target:Distance(gait.LastStep) > 5

		if hasTarget then
			wantsToMove = true
		end

		if gaitFraction > stance then
			if hasTarget or gait.Moving then
				gait.NextStep = self:NewFindGround(offset + vel, offset)

				local moveFraction = (gaitFraction - stance) / (1 - stance)
				local bezier = math.QuadraticBezier(moveFraction,
					gait.LastStep,
					LerpVector(0.5, gait.LastStep, gait.NextStep) + Vector(0, 0, 1) * 100,
					gait.NextStep)

				gait.RealStep = LerpVector(moveFraction, bezier, gait.NextStep)
				gait.Moving = true
			end
		elseif gait.Moving then
			gait.LastStep = gait.NextStep
			gait.RealStep = gait.NextStep

			gait.Moving = false
		end

		self.GlobalPos:Add(gait.RealStep)
	end

	if not wantsToMove then
		self.GaitFraction = 0
	end

	self.GlobalPos:Div(#self.Gaits)
	self.GlobalPos:Add(Vector(0, 0, self.GroundOffset))

	-- Need a better way to do this
	self.Bones.Root.Pos = self.GlobalPos

	for k, leg in ipairs(self.Legs) do
		leg.Pos = self.Gaits[k].RealStep

		-- IK is fucked right now, prone to spazzing out
		-- Probably going to have to port over and implement quaternions
		self:PerformLegIK(k, leg)
	end
end

function ENT:NewTraceDirection(distance, offset, direction, trace)
	trace = trace or {}

	trace.start = offset
	trace.endpos = offset + direction:GetNormalized() * (distance or 56756)

	if trace.mins then
		return util.TraceHull(trace)
	else
		return util.TraceLine(trace)
	end
end

-- Fix ground not found behavior
function ENT:NewFindGround(pos, origin)
	local traceOrigin = Vector(pos)
	traceOrigin.z = self:GetPos().z

	local trace = self:TraceDirection(self.GroundOffset * 1.5, traceOrigin, Vector(0, 0, -1), {
		mins = Vector(-5, -5, 0),
		maxs = Vector(5, 5, 0),
		filter = function(ent) return ent != self and ent:GetOwner() != self end
	})

	if not trace.StartSolid and trace.Hit then
		local dist = trace.HitPos:Distance(origin)

		-- NaN check
		if dist < 57 then
			return pos, self:GetUp()
		end

		return trace.HitPos, trace.HitNormal
	end

	return pos, self:GetUp()
end

function ENT:AddGait(timing, offset)
	local pos = self:LocalToWorld(offset)

	table.insert(self.Gaits, {
		Timing = timing,
		Offset = offset,

		LastStep = Vector(pos),
		NextStep = Vector(pos),
		RealStep = Vector(pos),

		Moving = false
	})
end

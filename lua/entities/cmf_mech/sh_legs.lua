AddCSLuaFile()

function ENT:InitLegs()
	self.Legs = {}
	self.LastGait = CurTime()

	self:AddLeg({
		Timing = 0,

		RootBone = self.Bones.Root,
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, 35, 0),
		Offset = Vector(0, 35, 0),

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self.Bones.LHip,
		Knee = self.Bones.LKnee,
		Foot = self.Bones.LFoot,

		LengthA = 38,
		LengthB = 85,
		FootOffset = 10
	})

	self:AddLeg({
		Timing = 0.5,

		RootBone = self.Bones.Root,
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, -35, 0),
		Offset = Vector(0, -35, 0),

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self.Bones.RHip,
		Knee = self.Bones.RKnee,
		Foot = self.Bones.RFoot,

		LengthA = 38,
		LengthB = 85,
		FootOffset = 10
	})
end

function ENT:UpdateLegs()
	self:RunGait()

	for _, leg in ipairs(self.Legs) do
		leg.Solver(self, leg)
	end
end

ENT.StepSize = 250
ENT.GroundOffset = 110
ENT.StepHeight = 100

local function clampVector2D(vel, length)
	if vel:Length2D() > length then
		vel:Normalize()
		vel:Mul(length)
	end
end

local groundTime = 0.25

function ENT:RunGait()
	local delta = CurTime() - self.LastGait
	local vel = self:GetMechVelocity()

	delta = delta * math.max(vel:Length2D() / self.StepSize, 0.5)

	clampVector2D(vel, self.StepSize / 4)

	local cycle = self:GetWalkCycle() + delta
	local wantsToMove = false

	for _, leg in ipairs(self.Legs) do
		local fraction = (cycle + leg.Timing) % 1
		local offset = self:LocalToWorld(leg.Offset)

		if not leg.Ground then
			local ground, normal = self:FindGround(offset)

			leg.Ground = ground
			leg.Pos = ground
			leg.Target = ground

			leg.OldNormal = normal
			leg.Normal = normal
		end

		local target, normal = self:FindGround(offset + vel)
		local hasTarget = target:Distance(leg.Ground) > 5

		if hasTarget or leg.Moving then
			wantsToMove = true
		end

		-- Maybe this does it?
		if fraction > 0.5 then
			if hasTarget or leg.Moving then
				leg.Target = target

				local moveFraction = (fraction - groundTime) / (1 - groundTime)
				local bezier = math.QuadraticBezier(moveFraction,
					leg.Ground,
					LerpVector(0.5, leg.Ground, leg.Target) + Vector(0, 0, 1) * self.StepHeight,
					leg.Target)

				leg.Pos = LerpVector(moveFraction, bezier, leg.Target)

				leg.Normal = math.CubicBezier(moveFraction,
					leg.OldNormal,
					(leg.Pos - leg.Ground):GetNormalized(),
					(leg.Pos - leg.Target):GetNormalized(),
					normal)
				leg.Normal:Normalize()

				leg.Moving = true
			end
		elseif leg.Moving then
			leg.Ground = leg.Target
			leg.Pos = leg.Target

			leg.Normal = normal
			leg.OldNormal = normal

			leg.Moving = false
		end
	end

	if not wantsToMove then
		self:SetWalkCycle(0)
	else
		self:SetWalkCycle(cycle % 1)
	end

	self.LastGait = CurTime()
end

local trace
local result = {}

function ENT:FindGround(offset)
	if not trace then
		trace = {
			mins = Vector(-5, -5, 0),
			maxs = Vector(5, 5, 0),
			filter = function(ent) return ent != self and ent:GetOwner() != self end,
			output = result
		}
	end

	trace.start = self:GetPos()
	trace.endpos = offset

	util.TraceLine(trace)

	if result.Hit then
		return result.HitPos, result.HitNormal
	end

	trace.start = result.HitPos
	trace.endpos = result.HitPos - self:GetUp() * 1000 -- Todo, probably not correct

	util.TraceLine(trace)

	return result.HitPos, result.Hit and result.HitNormal or self:GetUp()
end

function ENT:AddLeg(data)
	data.Moving = false

	table.insert(self.Legs, data)
end

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
		MaxLength = 38 + 85,

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
		MaxLength = 38 + 85,

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

ENT.GroundOffset = 110

local function clampVector2D(vel, length)
	if vel:Length2D() > length then
		vel:Normalize()
		vel:Mul(length)
	end
end

local function remapC(val, inMin, inMax, outMin, outMax)
	return math.Clamp(math.Remap(val, inMin, inMax, outMin, outMax), outMin, outMax)
end

function ENT:GetGaitData(vel)
	local rate = remapC(vel, self.WalkSpeed, self.RunSpeed, 0, 1)

	return Lerp(rate, 120, 180), Lerp(rate, 0.45, 0.6)
end

function ENT:RunGait()
	local delta = CurTime() - self.LastGait
	local vel = self:GetMechVelocity()

	local size, length = self:GetGaitData(vel:Length2D())
	local stepSize = size / length
	local mul = math.max(vel:Length2D() / stepSize, 0.5) * (1 - length) * 2

	delta = delta * mul

	clampVector2D(vel, stepSize / 4)

	local cycle = self:GetWalkCycle() + delta

	self:SetWalkCycle(cycle % 1)
	self.LastGait = CurTime()

	if not self:GetOnGround() then
		for _, leg in ipairs(self.Legs) do
			leg.Pos = self:LocalToWorld(leg.Offset - Vector(0, 0, self.GroundOffset * 0.75))
			leg.Ground = nil

			leg.Normal = self:GetUp()
		end

		self:SetGaitCenter(self:GetPos())
		self:SetWalkCycle(0)

		return
	end

	for _, leg in ipairs(self.Legs) do
		local gaitStart = leg.Timing
		local gaitEnd = leg.Timing + length

		local fraction = 0
		local canMove = false

		if cycle >= gaitStart and cycle <= gaitEnd then
			fraction = (cycle - gaitStart) / (gaitEnd - gaitStart)
			canMove = true
		elseif gaitStart < 0 then
			if cycle >= math.abs(gaitStart) and cycle <= 1 then
				fraction = (cycle - gaitStart) / (gaitEnd - gaitStart)
				canMove = true
			end
		elseif gaitEnd > 1 then
			if cycle + 1 >= gaitStart and cycle + 1 <= gaitEnd then
				fraction = (cycle + 1 - gaitStart) / (gaitEnd - gaitStart)
				canMove = true
			end
		end

		local offset = self:LocalToWorld(leg.Offset)

		if not leg.Ground then
			local ground, normal = self:FindGround(offset, leg.MaxLength * 2)

			leg.Ground = ground
			leg.Pos = ground
			leg.Target = ground

			leg.OldNormal = normal
			leg.Normal = normal
		end

		local target, normal = self:FindGround(offset + vel, leg.MaxLength * 1.5)
		local distance = target:Distance(leg.Ground)
		local hasTarget = distance > 5

		if canMove then
			if hasTarget or leg.Moving then
				leg.Target = target

				-- if CLIENT and not leg.Moving then
				-- 	leg.Temp = self:WorldToLocal(leg.Ground):Length2D()
				-- end

				-- Is GroundOffset still the best method to use here?
				local bezier = math.QuadraticBezier(fraction,
					leg.Ground,
					LerpVector(0.5, leg.Ground, leg.Target) + Vector(0, 0, 1) * math.min(distance * 0.5, self.GroundOffset),
					leg.Target)

				leg.Pos = LerpVector(fraction, bezier, leg.Target)

				local normalFraction = math.min(distance / self.GroundOffset, 1)

				local mid1 = LerpVector(normalFraction, leg.OldNormal, (leg.Pos - leg.Ground):GetNormalized())
				local mid2 = LerpVector(normalFraction, normal, (leg.Pos - leg.Target):GetNormalized())

				leg.Normal = math.CubicBezier(fraction, leg.OldNormal, mid1, mid2, normal)
				leg.Normal:Normalize()

				leg.Moving = true
			end
		elseif leg.Moving then
			leg.Ground = leg.Target
			leg.Pos = leg.Target

			leg.Normal = normal
			leg.OldNormal = normal

			-- if CLIENT then
			-- 	print("---", _, "---")
			-- 	print(self:WorldToLocal(leg.Target):Length2D() - leg.Temp)
			-- end

			leg.Moving = false
		end
	end

end

local trace
local result = {}

function ENT:FindGround(offset, maxLength)
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
	trace.endpos = result.HitPos - self:GetUp() * maxLength

	util.TraceLine(trace)

	return result.HitPos, result.Hit and result.HitNormal or self:GetUp()
end

function ENT:AddLeg(data)
	data.Moving = false

	table.insert(self.Legs, data)
end

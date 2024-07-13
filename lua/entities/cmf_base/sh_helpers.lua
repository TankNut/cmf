AddCSLuaFile()

function ENT:GetDriver()
	return self:GetSeat():GetDriver()
end

function ENT:HasDriver()
	return IsValid(self:GetDriver())
end

function ENT:GetLookAng()
	local ply = self:GetDriver()

	if not IsValid(ply) then
		return self:GetAngles()
	end

	return ply:LocalEyeAngles()
end

function ENT:GetGroundTrace()
	local pos = self:GetPos()

	return util.TraceHull({
		start = pos,
		endpos = pos - Vector(0, 0, 56756),
		filter = self,
		collisiongroup = COLLISION_GROUP_WEAPON,
		mins = Vector(-10, -10, 0),
		maxs = Vector(10, 10, 0)
	})
end

function ENT:GetRootBoneOffset()
	local run = self.Mech.RunSpeed

	local vel = self:GetVelocity()
	local fraction = self:GetMoveFraction()
	local cycle = self:GetWalkCycle()

	local length = vel:Length2D()

	local pos = Vector()
	local ang = Angle()

	do -- Walkcycle bob
		local offset = 0.1

		local magnitude = math.Remap(length, 0, run, 15, 10)
		local radians = math.Remap((cycle + offset) % 1, 0, 0.5, -math.pi, math.pi)

		pos.z = pos.z + math.sin(radians) * magnitude * fraction
	end

	-- Sideways velocity roll
	ang.r = ang.r + math.Remap(vel:Dot(-self:GetRight()), -run, run, -15, 15)

	do -- Walkcycle roll
		local offset = 0.125

		local magnitude = math.Remap(length, 0, run, 5, 10)
		local radians = math.Remap((cycle + offset) % 1, 0, 1, -math.pi, math.pi)

		ang.r = ang.r + math.sin(radians) * magnitude * fraction
	end

	return pos, ang
end

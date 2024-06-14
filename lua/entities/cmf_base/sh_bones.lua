AddCSLuaFile()

function ENT:InitBones()
	self.Bones = {}
	self.HitboxBones = {}

	-- Body
	self:CreateBone("")
	self:CreateBone("Torso")
	self:CreateBone("Weapons")

	-- Left leg
	self:CreateBone("LHip")
	self:CreateBone("LKnee")
	self:CreateBone("LFoot")

	-- Right leg
	self:CreateBone("RHip")
	self:CreateBone("RKnee")
	self:CreateBone("RFoot")
end

function ENT:GetRootBoneOffset()
	local vel = self:GetVelocity()
	local fraction = self:GetMoveFraction()
	local cycle = self:GetWalkCycle()

	local length = vel:Length2D()

	local pos = Vector()
	local ang = Angle()

	do -- Walkcycle bob
		local offset = 0.1

		local magnitude = math.Remap(length, 0, 530, 15, 10)
		local radians = math.Remap((cycle + offset) % 1, 0, 0.5, -math.pi, math.pi)

		pos.z = pos.z + math.sin(radians) * magnitude * fraction
	end

	-- Sideways velocity roll
	ang.r = ang.r + math.Remap(vel:Dot(-self:GetRight()), -530, 530, -15, 15)

	do -- Walkcycle roll
		local offset = 0.125

		local magnitude = math.Remap(length, 0, 530, 5, 10)
		local radians = math.Remap((cycle + offset) % 1, 0, 1, -math.pi, math.pi)

		ang.r = ang.r + math.sin(radians) * magnitude * fraction
	end

	return pos, ang
end

function ENT:UpdateBones()
	local rootBone = self.Bones[""]
	local torsoBone = self.Bones["Torso"]
	local weaponBone = self.Bones["Weapons"]

	local rootPos, rootAng = self:GetRootBoneOffset()

	rootBone.Pos = self:LocalToWorld(rootPos)
	rootBone.Ang = self:LocalToWorldAngles(rootAng)

	torsoBone.Pos = LocalToWorld(Vector(0, 0, 17), angle_zero, rootBone.Pos, rootBone.Ang)

	local ply = self:GetDriver()

	if IsValid(ply) then
		local eyeAng = ply:LocalEyeAngles()

		torsoBone.Ang = Angle(0, eyeAng.y, 0)
		weaponBone.Ang = Angle(eyeAng.p, eyeAng.y, 0)
	else
		torsoBone.Ang = rootBone.Ang
		weaponBone.Ang = rootBone.Ang
	end

	weaponBone.Pos = LocalToWorld(Vector(2, 0, 13), angle_zero, torsoBone.Pos, torsoBone.Ang)
end

function ENT:CreateBone(name)
	self.Bones[name] = {
		Pos = Vector(),
		Ang = Angle()
	}

	self.HitboxBones[name] = {}
end

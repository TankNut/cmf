AddCSLuaFile()

function ENT:UpdateBones()
	local rootBone = self.Bones["Root"]
	local torsoBone = self.Bones["Torso"]
	local weaponBone = self.Bones["Weapons"]

	-- Probably nice to get some sideways lean going
	rootBone.Ang = self:GetAngles()

	rootBone.Pos = self:GetPos()
	rootBone.Pos.z = self:GetGaitCenter().z

	torsoBone.Pos = self:RelativeToBone("Root", Vector(0, 0, 17))

	local ply = self:GetDriver()

	if IsValid(ply) then
		local eyeAng = ply:LocalEyeAngles()

		torsoBone.Ang = Angle(0, eyeAng.y, 0)
		weaponBone.Ang = Angle(eyeAng.p, eyeAng.y, 0)
	else
		torsoBone.Ang = rootBone.Ang
		weaponBone.Ang = rootBone.Ang
	end

	weaponBone.Pos = self:RelativeToBone("Torso", Vector(2, 0, 13))
end

function ENT:BuildBones()
	-- Body
	self:AddBone("Torso")
	self:AddBone("Weapons")

	-- Left leg
	self:AddBone("LHip")
	self:AddBone("LKnee")
	self:AddBone("LFoot")

	-- Right leg
	self:AddBone("RHip")
	self:AddBone("RKnee")
	self:AddBone("RFoot")
end

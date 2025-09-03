AddCSLuaFile()

function ENT:UpdateBones()
	local rootBone = self.Bones["Root"]
	local torsoBone = self.Bones["Torso"]

	-- Probably nice to get some sideways lean going
	rootBone.Ang = self:GetAngles()

	local offset = self:GetGaitOffset()
	offset:Rotate(rootBone.Ang)

	rootBone.Pos = self:GetPos()
	rootBone.Pos:Add(offset)

	local torso = self:GetAngles() + self:GetTorsoAngle()

	torsoBone.Pos = self:RelativeToBone("Root", Vector(0, 0, 13))
	torsoBone.Ang = Angle(0, torso.y)

	local leftWeapon = self.Bones["LWeapon"]
	leftWeapon.Pos = self:RelativeToBone("Torso", Vector(-23, 59, 22))
	leftWeapon.Ang = Angle(torso.p, torso.y)

	local rightWeapon = self.Bones["RWeapon"]
	rightWeapon.Pos = self:RelativeToBone("Torso", Vector(-23, -59, 22))
	rightWeapon.Ang = Angle(torso.p, torso.y)
end

function ENT:BuildBones()
	-- Body
	self:AddBone("Torso")

	self:AddBone("LWeapon")
	self:AddBone("RWeapon")

	-- Left leg
	self:AddBone("LHip")
	self:AddBone("LKnee")
	self:AddBone("LFoot")

	-- Right leg
	self:AddBone("RHip")
	self:AddBone("RKnee")
	self:AddBone("RFoot")
end

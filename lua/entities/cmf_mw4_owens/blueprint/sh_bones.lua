AddCSLuaFile()

function ENT:UpdateBones()
	local rootBone = self.Bones["Root"]
	local torsoBone = self.Bones["Torso"]
	local weaponBone = self.Bones["Weapons"]

	-- Probably nice to get some sideways lean going
	rootBone.Ang = self:GetAngles()

	local offset = self:GetGaitOffset()
	offset:Rotate(rootBone.Ang)

	rootBone.Pos = self:GetPos()
	rootBone.Pos:Add(offset)

	torsoBone.Pos = self:RelativeToBone("Root", Vector(0, 0, 17))

	local torso = self:GetAngles() + self:GetTorsoAngle()

	torsoBone.Ang = Angle(0, torso.y)
	weaponBone.Ang = Angle(torso.p, torso.y)

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

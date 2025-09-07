AddCSLuaFile()

function ENT:BuildBones()
	-- Body
	self:AddBone("Torso", {
		Parent = "Root",
		Offset = {
			Pos = Vector(0, 0, 17)
		},
		Turret = {
			NetworkVar = "TorsoAngle",
			Range = Angle(30, 130),
			Rate = 225,

			NoPitch = true
		}
	})

	self:AddBone("Weapons", {
		Parent = "Torso",
		Offset = {
			Pos = Vector(2, 0, 13)
		},
		Turret = {
			NetworkVar = "TorsoAngle",
			Slave = true,

			NoYaw = true
		}
	})

	-- Left leg
	self:AddBone("LHip")
	self:AddBone("LKnee")
	self:AddBone("LFoot")

	-- Right leg
	self:AddBone("RHip")
	self:AddBone("RKnee")
	self:AddBone("RFoot")
end

AddCSLuaFile()

function ENT:BuildBones()
	-- Body
	self:AddBone("Torso", {
		Parent = "Root",
		Offset = {
			Pos = Vector(0, 0, 13)
		},
		Turret = {
			NetworkVar = "TorsoAngle",
			Rate = 108,

			NoPitch = true
		}
	})

	self:AddBone("LWeapon", {
		Parent = "Torso",
		Offset = {
			Pos = Vector(-23, 59, 22)
		},
		Turret = {
			NetworkVar = "TorsoAngle",
			Slave = true,

			NoYaw = true
		}
	})

	self:AddBone("RWeapon", {
		Parent = "Torso",
		Offset = {
			Pos = Vector(-23, -59, 22)
		},
		Turret = {
			NetworkVar = "TorsoAngle",
			Slave = true,

			NoYaw = true
		}
	})

	self:AddBone("Chin", {
		Parent = "Torso",
		Offset = {
			Pos = Vector(70, 0, 15)
		},
		Turret = {
			NetworkVar = "ChinAngle",
			Range = Angle(30, 90),

			NoPitch = true
		}
	})

	self:AddBone("ChinGun", {
		Parent = "Chin",
		Offset = {
			Pos = Vector(2, 0, -14)
		},
		Turret = {
			NetworkVar = "ChinAngle",
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

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

	self:AddBone("LeftWeapon", {
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

	self:AddBone("RightWeapon", {
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
			Rate = 108,

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
	self:AddBone("LeftHip")
	self:AddBone("LeftKnee")
	self:AddBone("LeftFoot")

	-- Right leg
	self:AddBone("RightHip")
	self:AddBone("RightKnee")
	self:AddBone("RightFoot")
end

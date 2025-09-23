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

			NoPitch = true,
			Torso = true
		}
	})

	self:AddBone("LeftWeapon", {
		Parent = "Torso",
		Offset = {
			Pos = Vector(-23, 69, 22)
		},
		Turret = {
			NetworkVar = "LeftWeaponAngle",
			Pitch = {-90, 90},
			Yaw = {-15, 30},
			Rate = 108,
		}
	})

	self:AddBone("RightWeapon", {
		Parent = "Torso",
		Offset = {
			Pos = Vector(-23, -69, 22)
		},
		Turret = {
			NetworkVar = "RightWeaponAngle",
			Pitch = {-90, 90},
			Yaw = {-30, 15},
			Rate = 108
		}
	})

	self:AddBone("Chin", {
		Parent = "Torso",
		Offset = {
			Pos = Vector(70, 0, 2)
		},
		Turret = {
			NetworkVar = "ChinAngle",
			Pitch = {-30, 30},
			Yaw = {-90, 90},
			Rate = 200,

			NoPitch = true
		}
	})

	self:AddBone("ChinGun", {
		Parent = "Chin",
		Offset = {
			Pos = Vector(2, 0, 0)
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

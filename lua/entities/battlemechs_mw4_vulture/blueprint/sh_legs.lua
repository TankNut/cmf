AddCSLuaFile()

local spread = 44

function ENT:BuildLegs()
	self:AddLeg({
		Timing = 0,

		RootBone = self.Bones.Root,
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, spread, 0),
		Offset = Vector(0, spread, 0),
		MaxLength = self.UpperLength + self.LowerLength + self.FootOffset,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self.Bones.LeftHip,
		Knee = self.Bones.LeftKnee,
		Foot = self.Bones.LeftFoot,

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset,
	})

	self:AddLeg({
		Timing = 0.5,

		RootBone = self.Bones.Root,
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, -spread, 0),
		Offset = Vector(0, -spread, 0),
		MaxLength = self.UpperLength + self.LowerLength + self.FootOffset,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self.Bones.RightHip,
		Knee = self.Bones.RightKnee,
		Foot = self.Bones.RightFoot,

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset
	})
end

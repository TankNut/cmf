AddCSLuaFile()

local spread = 44

function ENT:BuildLegs()
	self:AddLeg({
		Timing = 0,

		RootBone = self.Bones.Root,
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, spread, 0),
		Offset = Vector(0, spread, 0),
		MaxLength = self.UpperLength + self.LowerLength,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self.Bones.LHip,
		Knee = self.Bones.LKnee,
		Foot = self.Bones.LFoot,

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset,

		DebugBones = {
			{self.Bones.LHip, self.Bones.LKnee},
			{self.Bones.LKnee, self.Bones.LFoot}
		}
	})

	self:AddLeg({
		Timing = 0.5,

		RootBone = self.Bones.Root,
		Rotation = Angle(0, 0, 0),

		Origin = Vector(0, -spread, 0),
		Offset = Vector(0, -spread, 0),
		MaxLength = self.UpperLength + self.LowerLength,

		Solver = self.IK_2Seg_Humanoid,
		Chicken = true,

		Hip = self.Bones.RHip,
		Knee = self.Bones.RKnee,
		Foot = self.Bones.RFoot,

		LengthA = self.UpperLength,
		LengthB = self.LowerLength,
		FootOffset = self.FootOffset
	})
end

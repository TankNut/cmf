AddCSLuaFile()

cmf.DefaultBones = {
	["root"] = true,
	["lhip"] = true,
	["lknee"] = true,
	["lfoot"] = true,
	["rhip"] = true,
	["rknee"] = true,
	["rfoot"] = true
}

local meta = cmf:Class("Mech")

function meta:AddBone(name)
	local bone = self.Bones[name]

	if not bone then
		bone = {
			Name = name,
			Parent = "",

			Position = Vector(),
			Angle = Angle(),

			OffsetPos = Vector(),
			OffsetAng = Angle(),

			LastUpdate = 0
		}

		self.Bones[name] = bone
		self.Modifiers[name] = {}
	end

	return bone
end

function meta:RemoveBone(name)
	assert(not cmf.DefaultBones[name])

	self.Bones[name] = nil
	self.Modifiers[name] = nil

	for _, bone in pairs(self.Bones) do
		if bone.Parent == name then
			bone.Parent = ""
		end
	end

	for _, hitbox in pairs(self.Hitboxes) do
		if hitbox.Bone == name then
			hitbox.Bone = ""
		end
	end

	for _, part in pairs(self.Parts) do
		if part.Bone == name then
			part.Bone = ""
		end
	end
end

function meta:AddDefaultBones()
	for name in pairs(cmf.DefaultBones) do
		self:AddBone(name)
	end
end

function meta:UpdateBone(bone)
	if bone.LastUpdate == FrameNumber() then
		return
	end

	local pos = self.Position
	local ang = self.Angle

	local parent = self.Bones[bone.Parent]

	if parent then
		self:UpdateBone(parent)

		pos = parent.Position
		ang = parent.Angle
	end

	bone.Position, bone.Angle = LocalToWorld(bone.OffsetPos, bone.OffsetAng, pos, ang)

	for _, modifier in pairs(self.Modifiers[bone.Name]) do
		self:ApplyModifier(bone, modifier)
	end

	bone.LastUpdate = FrameNumber()
end

function meta:UpdateBones()
	for _, bone in pairs(self.Bones) do
		self:UpdateBone(bone)
	end
end

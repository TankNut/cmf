AddCSLuaFile()

function ENT:InitBones()
	self.Bones = {}
	self.HitboxBones = {}

	self:AddBone("Root")

	self:BuildBones()
end

function ENT:RelativeToBone(name, pos, ang)
	local bone = self.Bones[name]

	return LocalToWorld(pos or vector_origin, ang or angle_zero, bone.Pos, bone.Ang)
end

function ENT:AddBone(name)
	assert(not self.Bones[name], string.format("A bone with the name '%s' already exists!", name))

	self.Bones[name] = {
		Pos = Vector(),
		Ang = Angle()
	}

	self.HitboxBones[name] = {}
end

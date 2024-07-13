AddCSLuaFile()

local meta = cmf:Class("Mech")

function meta:SerializeBone(bone)
	return {
		Parent = bone.Parent,

		OffsetPos = bone.OffsetPos,
		OffsetAng = bone.OffsetAng
	}
end

function meta:SerializeHitbox(hitbox)
	return {
		Bone = hitbox.Bone,

		Offset = hitbox.Offset,
		Angle = hitbox.Angle,

		Size = hitbox.Size
	}
end

function meta:SerializePart(part)
	return {
		Bone = part.Bone,
		RenderGroup = part.RenderGroup,

		Model = part.Model,
		Skin = part.Skin,

		Offset = part.Offset,
		Angle = part.Angle
	}
end

function meta:Serialize()
	local data = {
		Bones = {},
		Hitboxes = {},
		Parts = {},

		Name = self.Name,
		Author = self.Author,
		Version = self.Version,

		StandHeight = self.StandHeight,
		TurnRate = self.TurnRate,
		RunSpeed = self.RunSpeed,
		WalkSpeed = self.WalkSpeed,
		Acceleration = self.Acceleration,

		LegSpacing = self.LegSpacing,
		UpperLegLength = self.UpperLegLength,
		LowerLegLength = self.LowerLegLength,
		FootOffset = self.FootOffset,

		PhysboxMins = self.PhysboxMins,
		PhysboxMaxs = self.PhysboxMaxs
	}

	for index, bone in pairs(self.Bones) do
		data.Bones[index] = self:SerializeBone(bone)
	end

	for index, hitbox in pairs(self.Hitboxes) do
		data.Hitboxes[index] = self:SerializeHitbox(hitbox)
	end

	for index, part in pairs(self.Parts) do
		data.Parts[index] = self:SerializePart(part)
	end

	return data
end

function meta:Save(path)
	file.CreateDir(string.GetPathFromFilename(path))
	file.Write(path, util.TableToJSON(self:Serialize(), true))
end

function meta:Load(data)
	for k, v in pairs(data) do
		if istable(v) then
			continue
		end

		self[k] = v
	end

	for index, boneData in pairs(data.Bones) do
		local bone = self:AddBone(index)

		for k, v in pairs(boneData) do
			bone[k] = v
		end
	end

	for _, hitboxData in pairs(data.Hitboxes) do
		local hitbox = self:AddHitbox()

		for k, v in pairs(hitboxData) do
			hitbox[k] = v
		end
	end

	for _, partData in pairs(data.Parts) do
		local part = self:AddPart()

		for k, v in pairs(partData) do
			part[k] = v
		end
	end
end

function meta:LoadFromFile(path, static)
	assert(file.Exists(path, static and "GAME" or "DATA"))

	self:Load(util.JSONToTable(file.Read(path, static)))
end

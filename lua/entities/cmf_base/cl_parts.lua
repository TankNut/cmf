AddCSLuaFile()

if SERVER then
	return
end

function ENT:CreatePart(index, blueprint)
	local ent = ClientsideModel(blueprint.Model, blueprint.RenderGroup)

	ent:SetSkin(blueprint.Skin)

	self.Parts[index] = ent

	return ent
end

function ENT:UpdateParts()
	for index, blueprint in pairs(self.Blueprint.Parts) do
		local ent = self.Parts[index]

		if not IsValid(ent) then
			ent = self:CreatePart(index, blueprint)
		end

		ent:SetNoDraw(self:IsDormant())

		local pos, ang = LocalToWorld(blueprint.Offset, blueprint.Angle, self.Bones[blueprint.Bone].Pos, self.Bones[blueprint.Bone].Ang)

		-- NaN check
		if pos.x != pos.x then
			continue
		end

		ent:SetPos(pos)
		ent:SetAngles(ang)
	end
end

function ENT:ClearParts()
	for _, ent in pairs(self.Parts) do
		SafeRemoveEntity(ent)
	end
end

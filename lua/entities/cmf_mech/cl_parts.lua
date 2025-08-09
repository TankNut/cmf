function ENT:InitParts()
	if self.Parts then
		self:ClearParts()

		table.Empty(self.Parts)
	else
		self.Parts = {}
	end

	self:BuildModel()
end

function ENT:AddPart(data)
	assert(self.Bones[data.Bone], string.format("Bone '%s' does not exist!", bone))

	table.insert(self.Parts, data)
end

function ENT:CreatePart(part)
	local ent = ClientsideModel(part.Model, part.RenderGroup)

	ent:SetSkin(part.Skin or 0)

	part.Entity = ent
end

function ENT:UpdateParts()
	for _, part in pairs(self.Parts) do
		if not IsValid(part.Entity) then
			self:CreatePart(part)
		end

		part.Entity:SetNoDraw(self:IsDormant())

		local pos, ang = LocalToWorld(part.Pos, part.Ang, self.Bones[part.Bone].Pos, self.Bones[part.Bone].Ang)

		-- NaN check
		if pos.x != pos.x then
			continue
		end

		local ent = part.Entity

		ent:SetPos(pos)
		ent:SetAngles(ang)
	end
end

function ENT:ClearParts()
	for _, part in pairs(self.Parts) do
		SafeRemoveEntity(part.Entity)
	end
end

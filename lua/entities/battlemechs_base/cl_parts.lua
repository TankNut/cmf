function ENT:InitParts()
	if self.Parts then
		self:ClearParts()
	end

	self.Parts = {}
	self:BuildModel()
end

function ENT:AddPart(data)
	assert(self.Bones[data.Bone], string.format("Bone '%s' does not exist!", data.Bone))

	table.insert(self.Parts, data)

	if data.Type == cmf.MODEL then
		self:CreatePartEntity(data)
	end
end

function ENT:CreatePartEntity(part)
	local ent = ClientsideModel(part.Model, part.RenderGroup)

	ent:SetSkin(part.Skin or 0)
	ent:SetNoDraw(true)

	part.RenderGroup = ent:GetRenderGroup()
	part.Entity = ent
end

function ENT:DrawParts(flags, renderGroup)
	if self.FirstPersonSettings.HideParts and LocalPlayer() == self:GetDriver() and not self:GetSeat():GetThirdPersonMode() then
		return
	end

	for _, part in ipairs(self.Parts) do
		if part.RenderGroup == RENDERGROUP_BOTH or part.RenderGroup == renderGroup then
			self:DrawPart(part, flags)
		end
	end
end

function ENT:DrawModelPart(part, flags)
	if not IsValid(part.Entity) then
		self:CreatePartEntity(part)
	end

	local pos, ang = LocalToWorld(part.Pos, part.Ang, self.Bones[part.Bone].Pos, self.Bones[part.Bone].Ang)

	-- NaN check
	if pos.x != pos.x then
		return
	end

	local ent = part.Entity

	ent:SetPos(pos)
	ent:SetAngles(ang)

	ent:DrawModel(flags)
end

function ENT:DrawPart(part, flags)
	if part.Type == battlemechs.MODEL then
		self:DrawModelPart(part, flags)
	end
end

function ENT:ClearParts()
	for _, part in pairs(self.Parts) do
		SafeRemoveEntity(part.Entity)
	end
end

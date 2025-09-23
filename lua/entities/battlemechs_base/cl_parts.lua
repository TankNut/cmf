function ENT:InitParts()
	if self.Parts then
		self:ClearParts()
	end

	self.Parts = {}

	for _, v in ipairs(self.ModelData) do
		self:AddPart(v)
	end
end

function ENT:AddPart(data)
	assert(self.Bones[data.Bone], string.format("Bone '%s' does not exist!", data.Bone))

	table.insert(self.Parts, data)

	if data.Type == battlemechs.MODEL then
		self:CreatePartEntity(data)
	end
end

function ENT:CreatePartEntity(part)
	local ent = ClientsideModel(part.Model, part.RenderGroup)

	ent:SetSkin(part.Skin or 0)
	ent:SetNoDraw(true)

	part.Entity = ent

	return ent
end

function ENT:DrawParts(flags, renderGroup)
	local lp = LocalPlayer()

	if self.FirstPersonSettings.HideParts and lp == self:GetDriver() and not self:GetSeat():GetThirdPersonMode() and lp:GetViewEntity() == lp then
		return
	end

	for _, part in ipairs(self.Parts) do
		if not part.RenderGroup or part.RenderGroup == renderGroup then
			self:DrawPart(part, flags)
		end
	end
end

function ENT:DrawModelPart(part, flags)
	local ent = part.Entity

	if not IsValid(ent) then
		ent = self:CreatePartEntity(part)
	end

	self:UpdateModelPart(ent, part)

	local pos, ang = LocalToWorld(part.Pos, part.Ang, self.Bones[part.Bone].Pos, self.Bones[part.Bone].Ang)

	-- NaN check
	if pos.x != pos.x then
		return
	end

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

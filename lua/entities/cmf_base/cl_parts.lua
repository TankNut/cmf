AddCSLuaFile()

if SERVER then
	return
end

function ENT:InitParts()
	if self.Parts then
		self:ClearParts()
		table.Empty(self.Parts)
	else
		self.Parts = {}
	end

	self:AddPart("models/mw4addon/owens_hip.mdl", "", {})
	self:AddPart("models/mw4addon/owens_torso.mdl", "Torso", {
		Pos = Vector(2, 0, 0)
	})

	self:AddPart("models/mw4addon/owens_lgun.mdl", "Weapons", {
		Pos = Vector(0, 50, 0)
	})
	self:AddPart("models/mw4addon/owens_rgun.mdl", "Weapons", {
		Pos = Vector(0, -50, 0)
	})

	self:AddPart("models/mw4addon/owens_luleg.mdl", "LHip", {
		Pos = Vector(0, -23.5, 0),
		Ang = Angle(-157, 0, 0)
	})
	self:AddPart("models/mw4addon/owens_llleg.mdl", "LKnee", {
		Pos = Vector(0, -7, 0),
		Ang = Angle(-60, 0, 0)
	})
	self:AddPart("models/mw4addon/owens_lfoot.mdl", "LFoot", {
		Pos = Vector(0, 0, 13)
	})

	self:AddPart("models/mw4addon/owens_ruleg.mdl", "RHip", {
		Pos = Vector(0, 24, 0),
		Ang = Angle(-157, 0, 0)
	})
	self:AddPart("models/mw4addon/owens_rlleg.mdl", "RKnee", {
		Pos = Vector(0, 8, 0),
		Ang = Angle(-60, 0, 0)
	})
	self:AddPart("models/mw4addon/owens_rfoot.mdl", "RFoot", {
		Pos = Vector(0, 0, 13)
	})
end

function ENT:AddPart(mdl, bone, data)
	data = data or {}

	table.insert(self.Parts, {
		Bone = bone or "",

		RenderGroup = data.RenderGroup or RENDERGROUP_OPAQUE,

		Model = mdl,
		Skin = data.Skin or 0,

		Pos = data.Pos or Vector(),
		Ang = data.Ang or Angle()
	})
end

function ENT:CreatePart(part)
	local ent = ClientsideModel(part.Model, part.RenderGroup)

	ent:SetSkin(part.Skin)

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

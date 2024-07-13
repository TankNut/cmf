AddCSLuaFile()

local meta = cmf:Class("Mech")

function meta:AddPart()
	local part = {
		Bone = "",
		RenderGroup = RENDERGROUP_OPAQUE,

		Model = "models/props_lab/cactus.mdl",
		Skin = 0,

		Offset = Vector(),
		Angle = Angle(),

		LastUpdate = 0
	}

	table.insert(self.Parts, part)

	return part
end

function meta:RemovePart(index)
	table.remove(self.Parts, index)

	if CLIENT and self.ClientsideEntities[index] then
		SafeRemoveEntity(table.remove(self.ClientsideEntities, index))
	end
end

if CLIENT then
	function meta:CreatePartEntity(index, part)
		local ent = ClientsideModel(part.Model, part.RenderGroup)

		ent:SetSkin(part.Skin)

		self.ClientsideEntities[index] = ent

		return ent
	end

	function meta:UpdateParts()
		local dormant = false

		if self.Entity then
			dormant = self.Entity:IsDormant()
		end

		for index, part in pairs(self.Parts) do
			local ent = self.ClientsideEntities[index]

			if not IsValid(ent) then
				ent = self:CreatePartEntity(index, part)
			end

			ent:SetNoDraw(dormant)

			local originPos = self.Position
			local originAng = self.Angle

			local bone = self.Bones[part.Bone]

			if bone then
				originPos = bone.Position
				originAng = bone.Angle
			end

			local pos, ang = LocalToWorld(part.Offset, part.Angle, originPos, originAng)

			-- NaN check
			if pos.x != pos.x then
				continue
			end

			ent:SetPos(pos)
			ent:SetAngles(ang)
		end
	end
end

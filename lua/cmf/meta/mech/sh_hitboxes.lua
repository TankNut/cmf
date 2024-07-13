AddCSLuaFile()

local meta = cmf:Class("Mech")

function meta:AddHitbox()
	local hitbox = {
		Bone = "",

		Offset = Vector(),
		Angle = Angle(),

		Size = Vector()
	}

	table.insert(self.Hitboxes, hitbox)

	return hitbox
end

function meta:RemoveHitbox(index)
	table.remove(self.Hitboxes, index)
end

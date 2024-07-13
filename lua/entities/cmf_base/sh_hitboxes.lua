AddCSLuaFile()

function ENT:UpdateHitboxes()
	local bones = self.Mech.Bones
	for bone, group in pairs(self.HitboxBones) do
		local bonePos = bones[bone].Position
		local boneAng = bones[bone].Angle

		for _, hitbox in pairs(group) do
			local pos, ang = LocalToWorld(hitbox:GetHitboxPos(), hitbox:GetHitboxAng(), bonePos, boneAng)

			-- NaN check
			if pos.x != pos.x then
				continue
			end

			hitbox:SetPos(pos)
			hitbox:SetAngles(ang)
		end
	end
end

if SERVER then
	function ENT:CreateHitbox(bone, pos, ang, size)
		local ent = ents.Create("cmf_hitbox")
		local mins = Vector(0, -size.y * 0.5, -size.z * 0.5)
		local maxs = Vector(size.x, size.y * 0.5, size.z * 0.5)

		ent:SetPos(self:LocalToWorld(pos))
		ent:SetAngles(self:LocalToWorldAngles(ang))

		ent:SetOwner(self)

		ent:SetHitboxIndex(bone)

		ent:SetHitboxPos(pos)
		ent:SetHitboxAng(ang)

		ent:SetHitboxMins(mins)
		ent:SetHitboxMaxs(maxs)

		ent:Spawn()
		ent:Activate()

		self:DeleteOnRemove(ent)
	end
end

if CLIENT then
	local color = Color(0, 161, 255)

	function ENT:DrawHitboxes()
		for _, hitbox in pairs(self.Hitboxes) do
			render.DrawWireframeBox(hitbox:GetPos(), hitbox:GetAngles(), hitbox:GetHitboxMins(), hitbox:GetHitboxMaxs(), color)
		end
	end
end

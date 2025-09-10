AddCSLuaFile()

function ENT:InitHitboxes()
	if SERVER and self.Hitboxes then
		for _, ent in pairs(self.Hitboxes) do
			SafeRemoveEntity(ent)
		end
	end

	self.Hitboxes = {}

	if SERVER then
		self:BuildHitboxes()
	end
end

function ENT:UpdateHitboxes()
	for bone, group in pairs(self.HitboxBones) do
		local bonePos = self.Bones[bone].Pos
		local boneAng = self.Bones[bone].Ang

		for _, hitbox in ipairs(group) do
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
	function ENT:AddHitbox(bone, pos, ang, size)
		local ent = ents.Create("batthemechs_hitbox")
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

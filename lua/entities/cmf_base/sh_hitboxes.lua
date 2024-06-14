AddCSLuaFile()

function ENT:InitHitboxes()
	self.Hitboxes = {}

	if SERVER then
		self:CreateHitbox("Torso", Vector(-30, 0, -5), Angle(0, 0, 0), Vector(120, 60, 38))
		self:CreateHitbox("Torso", Vector(2.5, 0, -5), Angle(-90, 0, 0), Vector(55, 40, 40))
		self:CreateHitbox("Torso", Vector(-20, 0, 13), Angle(0, 0, 0), Vector(40, 100, 15))

		self:CreateHitbox("Weapons", Vector(-28, 65, 1), Angle(0, 0, -90), Vector(60, 47, 30))
		self:CreateHitbox("Weapons", Vector(-28, -65, 1), Angle(0, 0, 90), Vector(60, 47, 30))

		self:CreateHitbox("LHip",  Vector(-13, -12, 5), Angle(0, 0, 0),   Vector(self.UpperLength + 25, 13, 30))
		self:CreateHitbox("LKnee", Vector(-10, 0, -5),  Angle(-10, 0, 0), Vector(self.LowerLength + 10, 20, 30))
		self:CreateHitbox("LFoot", Vector(2, 2, 0),     Angle(-90, 0, 0), Vector(self.FootOffset, 40, 55))

		self:CreateHitbox("RHip",  Vector(-13, 12.5, 5), Angle(0, 0, 0),   Vector(self.UpperLength + 25, 13, 30))
		self:CreateHitbox("RKnee", Vector(-10, 0, -5),   Angle(-10, 0, 0), Vector(self.LowerLength + 10, 20, 30))
		self:CreateHitbox("RFoot", Vector(2, -2, 0),     Angle(-90, 0, 0), Vector(self.FootOffset, 40, 55))
	end
end

function ENT:UpdateHitboxes()
	for bone, group in pairs(self.HitboxBones) do
		local bonePos = self.Bones[bone].Pos
		local boneAng = self.Bones[bone].Ang

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

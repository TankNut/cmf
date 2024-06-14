AddCSLuaFile()

function ENT:InitPhysics()
	if IsValid(self.PhysCollide) then
		self.PhysCollide:Destroy()
	end

	self:EnableCustomCollisions(true)
	self:SetCollisionBounds(self.Mins, self.Maxs)
	self.PhysCollide = CreatePhysCollideBox(self.Mins, self.Maxs)

	if SERVER then
		self:PhysicsInitBox(self.Mins, self.Maxs, "solidmetal")
		self:SetSolid(SOLID_VPHYSICS)
	end
end

-- CONTENTS_GRATE runs for physguns but not for bullets
-- CONTENTS_HITBOX runs for bullets but not for physguns

function ENT:TestCollision(start, delta, isbox, extends, mask)
	if bit.band(mask, CONTENTS_GRATE) == 0 or not IsValid(self.PhysCollide) then
		return
	end

	local max = extends
	local min = -extends

	max.z = max.z - min.z
	min.z = 0

	local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), start, start + delta, min, max)

	if not hit then
		return
	end

	return {
		HitPos = hit,
		Normal = norm,
		Fraction = frac
	}
end

if CLIENT then
	local color = Color(255, 191, 0)

	function ENT:DrawPhysics()
		render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self.Mins, self.Maxs, color, true)
	end
end

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"

ENT.DisableDuplicator = true
ENT.PhysgunDisabled = true

ENT.BODY = 0
ENT.LEG_LEFT = 1
ENT.LEG_RIGHT = 2

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")

	local mech = self:GetOwner()

	table.insert(mech.Hitboxes, self)

	local index = self:GetHitboxIndex()

	if not mech.HitboxBones[index] then
		mech.HitboxBones[index] = {}
	end

	table.insert(mech.HitboxBones[index], self)

	local mins, maxs = self:GetHitboxMins(), self:GetHitboxMaxs()

	if IsValid(self.PhysCollide) then
		self.PhysCollide:Destroy()
	end

	self:EnableCustomCollisions(true)
	self:SetCollisionBounds(mins, maxs)
	self.PhysCollide = CreatePhysCollideBox(mins, maxs)

	if CLIENT then
		self:SetRenderBounds(mins, maxs)
	else
		self:PhysicsInitBox(mins, maxs, "solidmetal")
		self:SetSolid(SOLID_VPHYSICS)

		self:SetLagCompensated(true)
		self:SetUseType(SIMPLE_USE)
	end

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetNoDraw(true)
end

function ENT:SetupDataTables()
	self:NetworkVar("String", "HitboxIndex")

	self:NetworkVar("Vector", "HitboxMins")
	self:NetworkVar("Vector", "HitboxMaxs")

	self:NetworkVar("Vector", "HitboxPos")
	self:NetworkVar("Angle", "HitboxAng")
end

function ENT:TestCollision(start, delta, isbox, extends, mask)
	if bit.band(mask, CONTENTS_HITBOX) == 0 or not IsValid(self.PhysCollide) then
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

function ENT:CanTool()
	return false
end

function ENT:OnRemove()
	if self.PhysCollide then
		self.PhysCollide:Destroy()
	end
end

if CLIENT then
	function ENT:ImpactTrace(tr, damageType)
		local effectData = EffectData()

		effectData:SetEntity(self)
		effectData:SetOrigin(tr.HitPos)
		effectData:SetStart(tr.StartPos)
		effectData:SetSurfaceProp(util.GetSurfaceIndex("solidmetal"))
		effectData:SetDamageType(damageType)

		util.Effect("Impact", effectData)

		return true
	end
else
	function ENT:Use(ply)
		self:GetOwner():Use(ply)
	end
end

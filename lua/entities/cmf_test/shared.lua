AddCSLuaFile()

ENT.Type = "anim"
ENT.Spawnable = true

ENT.Mins = Vector(-16, -16, -16)
ENT.Maxs = Vector(16, 16, 16)

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")

	self:EnableCustomCollisions(true)
	self:PhysicsInitBox(self.Mins, self.Maxs)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Think()
	if SERVER then
		self:PhysWake()
	end

	self:NextThink(CurTime())

	return true
end

if CLIENT then
	local color = Color(255, 191, 0)

	function ENT:Draw()
		self:DrawModel()

		render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self.Mins, self.Maxs, color, true)
	end
end

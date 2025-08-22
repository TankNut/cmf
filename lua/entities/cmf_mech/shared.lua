AddCSLuaFile()

ENT.AutomaticFrameAdvance = true

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"

ENT.DisableDuplicator = true

-- Mech fields
ENT.DrawRadius = 200

ENT.Hull = {
	Mins = Vector(-48, -48, -16),
	Maxs = Vector(48, 48, 55)
}

ENT.GroundOffset = 110

ENT.MoveAcceleration = 400

ENT.LegSpacing = 35

ENT.UpperLength = 38
ENT.LowerLength = 85

ENT.FootOffset = 10

include("sh_bones.lua")
--include("sh_gait_new.lua")
--include("sh_gait.lua")
include("sh_hitboxes.lua")
include("sh_ik.lua")
include("sh_legs.lua")
include("sh_movement.lua")
include("sh_physics.lua")

include("sh_blueprint.lua")

AddCSLuaFile("cl_debug.lua")
AddCSLuaFile("cl_parts.lua")

if CLIENT then
	include("cl_debug.lua")
	include("cl_parts.lua")
end

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")
	self:DrawShadow(false)

	self:InitPhysics()
	self:InitMovement()

	self:InitBones()
	self:InitLegs()
	self:InitHitboxes()

	if CLIENT then
		local radius = self.DrawRadius

		self:InitParts()
		self:SetRenderBounds(self.Hull.Mins, self.Hull.Maxs, Vector(radius, radius, radius))

		hook.Add("PreDrawHUD", self, self.PreDrawHUD)
	else
		self:CreateSeat()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")

	self:NetworkVar("Bool", "OnGround")

	self:NetworkVar("Float", "WalkCycle")
	self:NetworkVar("Vector", "GaitOffset")

	self:NetworkVar("Vector", "MechVelocity")
end

function ENT:Think()
	self:PhysWake()

	self:UpdateBones()
	self:UpdateLegs()
	self:UpdateHitboxes()

	self:NextThink(CurTime())

	return true
end

if SERVER then
	function ENT:CreateSeat()
		self.Seat = ents.Create("prop_vehicle_prisoner_pod")
		self.Seat._cmfMech = self

		self.Seat:SetModel("models/props_lab/cactus.mdl")
		self.Seat:SetKeyValue("limitview", 0, 0)

		self.Seat:Spawn()

		self.Seat:SetParent(self)

		self.Seat:SetLocalPos(vector_origin)
		self.Seat:SetLocalAngles(angle_zero)

		self.Seat:SetSolid(SOLID_NONE)
		self.Seat:SetRenderMode(RENDERMODE_NONE)

		self:DeleteOnRemove(self.Seat)
		self:SetSeat(self.Seat)
	end

	function ENT:Use(ply)
		if not ply:KeyPressed(IN_USE) or self:HasDriver() then
			return
		end

		local dir = self:GetForward()

		dir.z = 0
		dir:Normalize()

		ply:EnterVehicle(self.Seat)
		ply:SetEyeAngles(dir:Angle())
	end
end

function ENT:GetDriver()
	return self:GetSeat():GetDriver()
end

function ENT:HasDriver()
	return IsValid(self:GetDriver())
end

function ENT:GetLookAng()
	local ply = self:GetDriver()

	if not IsValid(ply) then
		return self:GetAngles()
	end

	return ply:LocalEyeAngles()
end

function ENT:GetGroundTrace()
	local pos = self:GetPos()

	return util.TraceHull({
		start = pos,
		endpos = pos - Vector(0, 0, 56756),
		filter = self,
		collisiongroup = COLLISION_GROUP_WEAPON,
		mins = Vector(-10, -10, 0),
		maxs = Vector(10, 10, 0)
	})
end

function ENT:OnRemove()
	if self.PhysCollide then
		self.PhysCollide:Destroy()
	end

	if CLIENT then
		self:ClearParts()
	end
end

function ENT:OnReloaded()
	self:InitBones()
	self:InitLegs()
	self:InitHitboxes()

	if CLIENT then
		self:InitParts()
	end
end

if CLIENT then
	function ENT:PrePlayerDraw(ply, flags)
		return true
	end

	function ENT:PostPlayerDraw(ply, flags)
	end

	function ENT:CalcView(ply, origin, angles, fov, znear, zfar)
		if ply:GetViewEntity() != ply then
			return
		end

		self:UpdateBones()

		angles = ply:EyeAngles() + Angle(5, 0, 0)

		local seat = self:GetSeat()
		local thirdperson = seat:GetThirdPersonMode()

		if thirdperson then
			origin = self:LocalToWorld(Vector(0, 0, 20))

			local tr = util.TraceHull({
				start = origin,
				endpos = origin + (angles:Forward() * -250),
				mask = MASK_SOLID,
				filter = self,
				mins = Vector(-4, -4, -4),
				maxs = Vector(4, 4, 4),
			})

			origin = tr.HitPos
		else
			origin = self:RelativeToBone("Torso", Vector(50, 0, 20))
		end

		return {
			origin = origin,
			angles = angles,
			fov = fov,
			znear = znear,
			zfar = zfar,
			drawviewer = self:GetSeat():GetThirdPersonMode()
		}
	end

	function ENT:Draw(flags)
		self:DrawParts(flags, RENDERGROUP_OPAQUE)
	end

	function ENT:DrawTranslucent(flags)
		self:DrawParts(flags, RENDERGROUP_TRANSLUCENT)
	end

	function ENT:PreDrawHUD()
		if self:IsDormant() then
			return
		end

		cam.Start3D()
			self:DrawDebug()
		cam.End3D()
	end
end

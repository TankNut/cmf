AddCSLuaFile()

ENT.AutomaticFrameAdvance = true

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"
ENT.Category = "Custom Mech Framework"

ENT.Spawnable = true

ENT.DisableDuplicator = true

ENT.LegSpacing = 35

ENT.FootOffset = 10

ENT.UpperLength = 38
ENT.LowerLength = 85

ENT.TurnRate = 90

ENT.Mins = Vector(-48, -48, -16)
ENT.Maxs = Vector(48, 48, 62)

ENT.BODY = 0
ENT.LEG_LEFT = 1
ENT.LEG_RIGHT = 2

include("cl_parts.lua")

include("sh_bones.lua")
include("sh_gait.lua")
include("sh_hitboxes.lua")
include("sh_ik.lua")
include("sh_movement.lua")
include("sh_physics.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")

	self:InitPhysics()
	self:InitMovement()

	self:InitBones()
	self:InitHitboxes()

	self:InitLegs()

	if CLIENT then
		-- Bit excessive but rather safe than sorry
		local radius = math.max(self.UpperLength + self.LowerLength + self.FootOffset * 1.5, (self.Maxs - self.Mins):Length() * 0.5)

		self:InitParts()
		self:SetRenderBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))
	else
		self:CreateSeat()
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:CreateSeat()
	self.Seat = ents.Create("prop_vehicle_prisoner_pod")
	self.Seat._Mech = self

	self.Seat:SetModel("models/vehicles/pilot_seat.mdl")
	self.Seat:SetKeyValue("limitview", 0, 0)
	self.Seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")

	self.Seat:Spawn()

	self.Seat:SetParent(self)

	self.Seat:SetLocalPos(Vector(20, 0, -10))
	self.Seat:SetLocalAngles(Angle(0, -90, 0))

	self.Seat:SetSolid(SOLID_NONE)
	self.Seat:SetRenderMode(RENDERMODE_NONE)

	self:DeleteOnRemove(self.Seat)
	self:SetSeat(self.Seat)
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")

	self:NetworkVar("Float", "WalkCycle")

	self:NetworkVar("Vector", "MechVelocity")
end

function ENT:Think()
	self:PhysWake()

	self:UpdateBones()
	self:UpdateLegs()
	self:UpdateHitboxes()

	if CLIENT then
		self:UpdateParts()
	end

	self:NextThink(CurTime())

	return true
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
	if CLIENT then
		self:InitParts()
	end
end

if CLIENT then
	local convar = GetConVar("developer")

	function ENT:Draw()
		if convar:GetBool() then
			self:DrawPhysics()
			self:DrawHitboxes()
			self:DrawLegs()
		end
	end

	function ENT:CalcView(ply, origin, angles, fov, znear, zfar)
		if ply:GetViewEntity() != ply then
			return
		end

		angles = ply:EyeAngles()

		local seat = self:GetSeat()
		local thirdperson = seat:GetThirdPersonMode()

		if thirdperson then
			origin = self:LocalToWorld(Vector(0, 0, 30))

			local mins, maxs = seat:GetRenderBounds()
			local radius = (mins - maxs):Length()

			radius = radius + radius * seat:GetCameraDistance()

			local tr = util.TraceHull({
				start = origin,
				endpos = origin + (angles:Forward() * -radius),
				mask = MASK_OPAQUE,
				mins = Vector(-4, -4, -4),
				maxs = Vector(4, 4, 4),
			})

			origin = tr.HitPos
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

	function ENT:PrePlayerDraw(ply, flags)
		return true
	end
else
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

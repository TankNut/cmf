AddCSLuaFile()

ENT.AutomaticFrameAdvance = true

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"
ENT.Category = "Custom Mech Framework"

ENT.Spawnable = true
ENT.DisableDuplicator = true

include("sh_mech.lua")
include("sh_helpers.lua")
include("sh_hitboxes.lua")
include("sh_movement.lua")
include("sh_physics.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")

	self.Bones = {}

	self.Hitboxes = {}
	self.HitboxBones = {}

	if CLIENT then
		if self.Mech then
			self:LoadMech()
		else
			self:RequestMech()
		end

		return
	else
		self:SetUseType(SIMPLE_USE)
	end

	if not self.Mech then
		-- Error out, currently loads a pre-defined blueprint for testing
		self.Mech = cmf:Instance("Mech")
		self.Mech:LoadFromFile("cmf/test.json")
	end

	self:CreateSeat()
	self:LoadMech()

	-- Encode and compress once so people can easily request it later
	self.DataCache = util.Compress(cmf:Encode(self.Mech:Serialize()))
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")

	self:NetworkVar("Float", "WalkCycle")

	self:NetworkVar("Vector", "MechVelocity")
end

function ENT:Think()
	self:NextThink(CurTime())
	self:PhysWake()

	local mech = self.Mech

	if not mech then
		return true
	end

	mech.Position = self:GetPos()
	mech.Angle = self:GetAngles()
	mech.Velocity = self:GetMoveVelocity()

	mech.WalkCycle = self:GetWalkCycle()

	mech:Think()

	self:SetWalkCycle(mech.WalkCycle)

	self:UpdateHitboxes()

	return true
end

function ENT:OnRemove()
	if self.PhysCollide then
		self.PhysCollide:Destroy()
	end

	if self.Mech then
		self.Mech:Remove()
	end
end

if CLIENT then
	local convar = GetConVar("developer")

	function ENT:Draw()
		if not self.Mech then
			return
		end

		if convar:GetBool() then
			self:DrawPhysics()
			self:DrawHitboxes()
			--self.Mech:DrawBones()
		end
	end

	function ENT:PrePlayerDraw(ply, flags)
		return true
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
			drawviewer = seat:GetThirdPersonMode()
		}
	end
else
	function ENT:CreateSeat()
		self.Seat = ents.Create("prop_vehicle_prisoner_pod")
		self.Seat._Mech = self

		self.Seat:SetModel("models/vehicles/pilot_seat.mdl")
		self.Seat:SetKeyValue("limitview", 0, 0)

		self.Seat:Spawn()

		self.Seat:SetParent(self)

		self.Seat:SetLocalPos(vector_origin)
		self.Seat:SetLocalAngles(Angle(0, -90, 0))

		self.Seat:SetRenderMode(RENDERMODE_NONE)
		self.Seat:SetSolid(SOLID_NONE)
		self.Seat:DrawShadow(false)

		self:DeleteOnRemove(self.Seat)
		self:SetSeat(self.Seat)
	end

	function ENT:Use(ply)
		if not self.Mech then
			return
		end

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

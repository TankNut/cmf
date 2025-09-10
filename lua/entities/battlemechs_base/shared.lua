AddCSLuaFile()

ENT.AutomaticFrameAdvance = true

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"

ENT.DisableDuplicator = true

-- [MoveStat] indicates a value can vary based on how fast the mech is going relative to the clamped walk and run speeds (where walk = 0 and run = 1)
-- A table value is linearly interpolated based on the movement fraction
-- Functions are called with self and the movement fraction
-- Every other type of value is passed along without modification

-- Movement related fields
ENT.Hull = {-- The size of the mech's collision hull, this is only used for movement. Keep it off the ground so it doesn't catch on any bumps
	Mins = Vector(-48, -48, -16),
	Maxs = Vector(48, 48, 55)
}

ENT.GroundOffset = 110 -- How far above the ground the mech sits

ENT.MoveAcceleration = 400 -- Hammer units/s of acceleration when moving or slowing down
ENT.MaxSlope = 40 -- The steepest slope a mech can walk on, any steeper and it'll start sliding down

ENT.WalkSpeed = 200 -- The target speed when walking normally
ENT.RunSpeed = 600 -- The target speed when +speed is held down

ENT.TurnRate = 90 -- [MoveStat] Degrees/s the mech can turn

-- Gait/leg related fields
ENT.StepSize = {160, 220} -- [MoveStat] The horizontal side of each step the mech takes
ENT.Stance = {0.45, 0.65} -- [MoveStat] Fraction of time each leg spends in the air
ENT.ForwardLean = {1.1, 1.4} -- [MoveStat] How far off-center the mech's legs are when moving

ENT.SideStep = 10 -- [MoveStat] The amount of side offset that's applied to the gait offset value
ENT.UpStep = {2, 1} -- [MoveStat] The amount of upwards offset that's applied to the gait offset value

-- Camera
ENT.FirstPersonSettings = {
	Bone = nil,
	Pos = Vector(0, 0, 0)
}

ENT.ThirdPersonSettings = {
	Distance = 400,
	Pos = Vector(0, 0, 100),

	HideParts = true
}

-- Misc fields
ENT.DrawRadius = 200 -- The radius that's added on top of ENT.Hull to determine the mech's render bounds

include("sh_bones.lua")
include("sh_helpers.lua")
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

	self:CreateNetworkVars()
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
		self.Seat._battlemech = self

		self.Seat:SetModel("models/props_lab/cactus.mdl")
		self.Seat:SetKeyValue("limitview", 0, 0)

		self.Seat:Spawn()

		self.Seat:SetParent(self)
		self.Seat:SetTransmitWithParent(true)

		self.Seat:SetLocalPos(vector_origin)
		self.Seat:SetLocalAngles(angle_zero)

		self.Seat:SetSolid(SOLID_NONE)
		self.Seat:SetRenderMode(RENDERMODE_NONE)
		self.Seat:DrawShadow(false)

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
		self.Debug_HitboxCache = nil

		self:InitParts()
	end
end

if CLIENT then
	function ENT:PrePlayerDraw(ply, flags)
		--ply:SetPos(self:LocalToWorld(Vector(0, 0, -50)))
		return true
	end

	function ENT:PostPlayerDraw(ply, flags)
	end

	function ENT:CalcView(ply, origin, angles, fov, znear, zfar)
		if ply:GetViewEntity() != ply then
			return
		end

		self:UpdateBones()

		origin, angles = self:GetViewOrigin()

		return {
			origin = origin,
			angles = angles,
			fov = fov,
			znear = znear,
			zfar = zfar,
			drawviewer = thirdperson
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

AddCSLuaFile()

ENT.AutomaticFrameAdvance = true

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Author = "TankNut"
ENT.Category = "Custom Mech Framework"

ENT.Spawnable = true
ENT.DisableDuplicator = true

ENT.BODY = 0
ENT.LEG_LEFT = 1
ENT.LEG_RIGHT = 2

include("cl_parts.lua")
include("sh_blueprint.lua")
include("sh_bones.lua")
include("sh_gait.lua")
include("sh_hitboxes.lua")
include("sh_legs.lua")
include("sh_movement.lua")
include("sh_physics.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/cactus.mdl")

	self.Bones = {}

	self.Hitboxes = {}
	self.HitboxBones = {}

	if CLIENT then
		self.Parts = {}

		if self.Blueprint then
			self:LoadBlueprint()
		else
			self:RequestBlueprint()
		end

		return
	else
		self:SetUseType(SIMPLE_USE)
	end

	if not self.Blueprint then
		-- Error out, currently loads a pre-defined blueprint for testing
		self.Blueprint = cmf:LoadBlueprint("cmf/test.json")
	end

	self:CreateSeat()
	self:LoadBlueprint()

	-- Encode and compress once so people can easily request it later
	self.BlueprintCache = util.Compress(cmf:Encode(self.Blueprint))
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", "Seat")

	self:NetworkVar("Float", "WalkCycle")

	self:NetworkVar("Vector", "MechVelocity")
end

function ENT:Think()
	self:NextThink(CurTime())
	self:PhysWake()

	if not self.Loaded then
		return true
	end

	self:UpdateBones()
	self:RunGait()
	self:UpdateHitboxes()

	if CLIENT then
		self:UpdateParts()
	end

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

if CLIENT then
	local convar = GetConVar("developer")

	function ENT:Draw()
		if not self.Loaded then
			return
		end

		if convar:GetBool() then
			self:DrawPhysics()
			self:DrawHitboxes()
			self:DrawBones()
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
else
	function ENT:CreateSeat()
		self.Seat = ents.Create("prop_vehicle_prisoner_pod")
		self.Seat._Mech = self

		self.Seat:SetModel("models/vehicles/pilot_seat.mdl")
		self.Seat:SetKeyValue("limitview", 0, 0)

		self.Seat:Spawn()

		self.Seat:SetParent(self)

		self.Seat:SetLocalPos(vector_origin)
		self.Seat:SetLocalAngles(angle_zero)

		self.Seat:SetSolid(SOLID_NONE)

		self:DeleteOnRemove(self.Seat)
		self:SetSeat(self.Seat)
	end

	function ENT:Use(ply)
		if not self.Loaded then
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

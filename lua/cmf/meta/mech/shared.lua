AddCSLuaFile()

local meta = cmf:Class("Mech")

include("sh_bones.lua")
include("sh_gait.lua")
include("sh_hitboxes.lua")
include("sh_ik.lua")
include("sh_parts.lua")
include("sh_serialization.lua")

function meta:Initialize()
	self.Bones = {}
	self.Hitboxes = {}
	self.Parts = {}

	if CLIENT then
		self.ClientsideEntities = {}
	end

	-- Blueprint stuff
	self.Name = "Unnamed Mech"
	self.Author = "Unknown"
	self.Version = "v1"

	self.StandHeight = 0
	self.TurnRate = 90 -- Degrees/sec
	self.RunSpeed = 530
	self.WalkSpeed = 200
	self.Acceleration = 400

	self.LegSpacing = 0
	self.UpperLegLength = 0
	self.LowerLegLength = 0
	self.FootOffset = 0

	self.PhysboxMins = Vector()
	self.PhysboxMaxs = Vector()

	-- Internals
	self.Position = Vector()
	self.Angle = Angle()

	self.Velocity = Vector()

	self:AddDefaultBones()

	self.LastGaitUpdate = CurTime()

	self.Legs = {
		{
			CycleOffset = 0,
			Offset = 1,
			Hip = self.Bones.lhip,
			Knee = self.Bones.lknee,
			Foot = self.Bones.lfoot
		}, {
			CycleOffset = 0.5,
			Offset = -1,
			Hip = self.Bones.rhip,
			Knee = self.Bones.rknee,
			Foot = self.Bones.rfoot
		}
	}

	self.WalkCycle = 0
end

function meta:Think()
	self:RunGait()
	self:UpdateBones()

	if CLIENT then
		self:UpdateParts()
	end
end

function meta:Remove()
	if CLIENT then
		for _, ent in pairs(self.ClientsideEntities) do
			SafeRemoveEntity(ent)
		end
	end
end

function meta:LocalToWorld(pos)
	local ret = LocalToWorld(pos, angle_zero, self.Position, self.Angle)

	return ret
end

function meta:LocalToWorldAngles(ang)
	local _, ret = LocalToWorld(vector_origin, ang, self.Position, self.Angle)

	return ret
end

function meta:WorldToLocal(pos)
	local ret = WorldToLocal(pos, angle_zero, self.Position, self.Angle)

	return ret
end

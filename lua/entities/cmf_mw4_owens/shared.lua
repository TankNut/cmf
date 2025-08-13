AddCSLuaFile()

ENT.Base = "cmf_mech"

ENT.PrintName = "Owens"
ENT.Category = "CMF: Mechwarrior 4"

ENT.Author = "TankNut"

ENT.Spawnable = true

include("blueprint/sh_bones.lua")

AddCSLuaFile("blueprint/cl_model.lua")

if CLIENT then
	include("blueprint/cl_model.lua")
else
	include("blueprint/sv_hitboxes.lua")
end

ENT.DrawRadius = 200

ENT.Hull = {
	Mins = Vector(-48, -48, -16),
	Maxs = Vector(48, 48, 55)
}

ENT.GroundOffset = 110

ENT.MoveAcceleration = 200

ENT.WalkSpeed = 200
ENT.RunSpeed = 600

ENT.TurnRate = 90

ENT.MaxSlope = 40

ENT.MoveFraction = 150

ENT.LegSpacing = 35

ENT.UpperLength = 38
ENT.LowerLength = 85

ENT.FootOffset = 10

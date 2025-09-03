AddCSLuaFile()
DEFINE_BASECLASS("cmf_mech")

ENT.Base = "cmf_mech"

ENT.PrintName = "Vulture"
ENT.Category = "CMF: Mechwarrior 4"

ENT.Author = "TankNut"

ENT.Spawnable = true

-- Movement related fields
ENT.Hull = {-- The size of the mech's collision hull, this is only used for movement. Keep it off the ground so it doesn't catch on any bumps
	Mins = Vector(-64, -64, -5),
	Maxs = Vector(64, 64, 105)
}

ENT.GroundOffset = 135 -- How far above the ground the mech sits

ENT.MoveAcceleration = 200 -- Hammer units/s of acceleration when moving or slowing down
ENT.MaxSlope = 40 -- The steepest slope a mech can walk on, any steeper and it'll start sliding down

ENT.WalkSpeed = 200 -- The target speed when walking normally
ENT.RunSpeed = 600 -- The target speed when +speed is held down

ENT.TurnRate = 70 -- [MoveStat] Degrees/s the mech can turn

-- Gait/leg related fields
ENT.StepSize = {160, 250} -- [MoveStat] The forward length of each step the mech takes
ENT.Stance = {0.45, 0.65} -- [MoveStat] Fraction of time each leg spends in the air
ENT.ForwardLean = {1.1, 1.3} -- [MoveStat] How far off-center the mech's legs are when moving

ENT.SideStep = 10 -- [MoveStat] The amount of side offset that's applied to the gait offset value
ENT.UpStep = {1.5, 1} -- [MoveStat] The amount of upwards offset that's applied to the gait offset value

-- Torso fields
ENT.TorsoRange = {Angle(), Angle()}
ENT.TorsoTurnRate = 108

-- Misc fields
ENT.DrawRadius = 200 -- The radius that's added on top of ENT.Hull to determine the mech's render bounds

ENT.UpperLength = 60
ENT.LowerLength = 68

ENT.FootOffset = 32

include("blueprint/sh_bones.lua")
include("blueprint/sh_hitboxes.lua")
include("blueprint/sh_legs.lua")

AddCSLuaFile("blueprint/cl_model.lua")

if CLIENT then
	include("blueprint/cl_model.lua")
end

AddCSLuaFile()

cmf = cmf or {}

function cmf:IncludeClient(path)
	AddCSLuaFile(path)

	if CLIENT then
		return include(path)
	end
end

include("sh_meta.lua")

include("editor/shared.lua")
include("meta/mech/shared.lua")

include("sh_callbacks.lua")
include("sh_hook.lua")
include("sh_modifiers.lua")
include("sh_pack.lua")

if CLIENT then
	cmf:Hook("CalcView")
	cmf:Hook("PrePlayerDraw")
end

function cmf:GetMech(ply)
	return ply:GetNWEntity("cmf-mech")
end

if SERVER then
	hook.Add("PlayerEnteredVehicle", "cmf", function(ply, vehicle)
		local mech = vehicle._Mech

		if IsValid(mech) then
			ply:SetNWEntity("cmf-mech", mech)
		end
	end)

	hook.Add("PlayerLeaveVehicle", "cmf", function(ply, vehicle)
		if IsValid(vehicle._Mech) then
			ply:SetNWEntity("cmf-mech", NULL)
		end
	end)
end

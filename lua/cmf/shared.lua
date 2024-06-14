AddCSLuaFile()

cmf = cmf or {}

include("sh_hook.lua")

if CLIENT then
	cmf:Hook("CalcView")
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

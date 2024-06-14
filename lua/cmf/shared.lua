AddCSLuaFile()

cmf = cmf or {}

function cmf:Hook(name)
	hook.Add(name, "cmf", function(ply, ...)
		local mech = self:GetMech(ply)

		if not IsValid(mech) or not mech[name] then
			return
		end

		return mech[name](mech, ply, ...)
	end)
end

if CLIENT then
	function cmf:HookLocal(name)
		hook.Add(name, "cmf", function(...)
			local mech = self:GetMech(LocalPlayer())

			if not IsValid(mech) or not mech[name] then
				return
			end

			return mech[name](mech, ...)
		end)
	end
end

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

AddCSLuaFile()

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

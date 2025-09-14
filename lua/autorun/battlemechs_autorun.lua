battlemechs = battlemechs or {}

function battlemechs:GetMech(ply)
	return ply:GetNWEntity("battlemechs.mech")
end

function battlemechs:Hook(name)
	hook.Add(name, "battlemechs", function(ply, ...)
		local mech = self:GetMech(ply)

		if not IsValid(mech) or not mech[name] then
			return
		end

		return mech[name](mech, ply, ...)
	end)
end

function battlemechs:SimpleBone(parent, pos, ang)
	return {
		Parent = parent,
		Offset = {
			Pos = pos,
			Ang = ang
		}
	}
end

battlemechs.STATE_OFFLINE   = 0
battlemechs.STATE_ONLINE    = 1
battlemechs.STATE_POWERDOWN = 2
battlemechs.STATE_POWERUP   = 3
battlemechs.STATE_CRITICAL  = 4

battlemechs:Hook("PlayerButtonDown")
battlemechs:Hook("PlayerButtonUp")

if CLIENT then
	function battlemechs:HookLocal(name)
		hook.Add(name, "battlemechs", function(...)
			local mech = self:GetMech(LocalPlayer())

			if not IsValid(mech) or not mech[name] then
				return
			end

			return mech[name](mech, ...)
		end)
	end

	battlemechs:Hook("CalcView")
	battlemechs:Hook("PrePlayerDraw")
	battlemechs:Hook("PostPlayerDraw")

	function battlemechs:DrawWorldText(pos, text, noz)
		local screen = pos:ToScreen()

		if not screen.visible then
			return
		end

		cam.IgnoreZ(true)
		cam.Start2D()
			surface.SetFont("BudgetLabel")

			local w, h = surface.GetTextSize("BudgetLabel", text)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(screen.x - w * 0.5, screen.y - h * 0.5)

			surface.DrawText(text)
		cam.End2D()
		cam.IgnoreZ(false)
	end

	battlemechs.MODEL = 1

	function battlemechs:ModelPart(mdl, bone, data)
		data = data or {}

		data.Type = self.MODEL
		data.Model = Model(mdl)
		data.Bone = bone

		data.Pos = data.Pos or Vector()
		data.Ang = data.Ang or Angle()

		return data
	end
else
	hook.Add("PlayerEnteredVehicle", "battlemechs", function(ply, vehicle)
		local mech = vehicle._battlemech

		if IsValid(mech) then
			ply:SetNWEntity("battlemechs.mech", mech)
			ply:DrawShadow(false)
		end
	end)

	hook.Add("PlayerLeaveVehicle", "cmf", function(ply, vehicle)
		if IsValid(vehicle._battlemech) then
			ply:SetNWEntity("battlemechs.mech", NULL)
			ply:DrawShadow(true)
		end
	end)
end

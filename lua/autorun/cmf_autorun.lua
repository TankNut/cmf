cmf = cmf or {}

function cmf:GetMech(ply)
	return ply:GetNWEntity("cmf.mech")
end

function cmf:Hook(name)
	hook.Add(name, "cmf", function(ply, ...)
		local mech = self:GetMech(ply)

		if not IsValid(mech) or not mech[name] then
			return
		end

		return mech[name](mech, ply, ...)
	end)
end

function cmf:SimpleBone(parent, pos, ang)
	return {
		Parent = parent,
		Offset = {
			Pos = pos,
			Ang = ang
		}
	}
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

	cmf:Hook("CalcView")
	cmf:Hook("PrePlayerDraw")
	cmf:Hook("PostPlayerDraw")

	function cmf:DrawWorldText(pos, text, noz)
		local screen = pos:ToScreen()

		if not screen.visible then
			return
		end

		cam.IgnoreZ(true)
		cam.Start2D()
			surface.SetFont("BudgetLabel")

			local w, h = surface.GetFontSize("BudgetLabel", text)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(screen.x - w * 0.5, screen.y - h * 0.5)

			surface.DrawText(text)
		cam.End2D()
		cam.IgnoreZ(false)
	end

	cmf.MODEL = 1

	function cmf:ModelPart(mdl, bone, data)
		data = data or {}

		data.Type = self.MODEL
		data.Model = Model(mdl)
		data.Bone = bone

		data.Pos = data.Pos or Vector()
		data.Ang = data.Ang or Angle()

		return data
	end
else
	hook.Add("PlayerEnteredVehicle", "cmf", function(ply, vehicle)
		local mech = vehicle._cmfMech

		if IsValid(mech) then
			ply:SetNWEntity("cmf.mech", mech)
			ply:DrawShadow(false)
		end
	end)

	hook.Add("PlayerLeaveVehicle", "cmf", function(ply, vehicle)
		if IsValid(vehicle._cmfMech) then
			ply:SetNWEntity("cmf.mech", NULL)
			ply:DrawShadow(true)
		end
	end)
end

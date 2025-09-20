AddCSLuaFile()

battlemechs = battlemechs or {}

include("sh_convars.lua")
include("sh_hooks.lua")

function battlemechs:GetMech(ply)
	return ply:GetNWEntity("battlemechs.mech")
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

function battlemechs:MW4Scale(x, y, z)
	return Vector(x * 25, y * 25, z * 25)
end

if CLIENT then
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
end

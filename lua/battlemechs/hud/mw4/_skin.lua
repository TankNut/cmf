local SKIN = {}

SKIN.Hue = 120

SKIN.Colors = {}
SKIN.Colors.Border = HSVToColor(SKIN.Hue, 1, 0.4)
SKIN.Colors.Fill = HSVToColor(SKIN.Hue, 1, 0.2)
SKIN.Colors.Fill.a = 230

function SKIN:PaintPanel(pnl, w, h)
	surface.SetDrawColor(self.Colors.Fill)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self.Colors.Border)
	surface.DrawOutlinedRect(0, 0, w, h)
end

derma.DefineSkin("Battlemechs_MW4", "Battlemechs HUD skin", SKIN)

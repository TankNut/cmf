local margin = ScreenScale(10)
local spacing = ScreenScale(2.5)

local borderColor = Color(0, 100, 0)
local fillColor = Color(0, 50, 0, 230)

function ENT:DrawFilledRect(x, y, w, h, border, fill)
	surface.SetDrawColor(fillColor)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(border)
	surface.DrawOutlinedRect(x, y, w, h)
end

local health1Color = Color(100, 200, 100)
local health2Color = Color(200, 200, 0)
local health3Color = Color(200, 100, 0)
local health4Color = Color(150, 25, 25)
local health5Color = Color(0, 0, 0, 200)

function ENT:DrawHealthBar(x, y, w, h, fraction)
	local col = health5Color

	if fraction > 0.75 then
		col = health1Color
	elseif fraction > 0.5 then
		col = health2Color
	elseif fraction > 0.25 then
		col = health3Color
	elseif fraction > 0 then
		col = health4Color
	end

	local w2 = w

	if fraction > 0 then
		w2 = math.Remap(fraction, 0, 1, 0, w)
	end

	surface.SetDrawColor(col)
	surface.DrawRect(x, y, w2, h)

	surface.SetDrawColor(borderColor)
	surface.DrawOutlinedRect(x, y, w, h)
end

function ENT:PaintHUDHealth()
	local data = self.HUDData

	local panelWidth = ScreenScale(100)

	local barWidth = panelWidth - spacing * 3
	local barHeight = ScreenScale(5)

	local groups = self.DamageGroups

	surface.SetFont("HudDefault")
	local _, textHeight = surface.GetTextSize("A")

	local panelHeight = #groups * (spacing + textHeight + barHeight) + spacing * 2

	local x = data.Left
	local y = data.Bottom - panelHeight

	self:DrawFilledRect(x, y, panelWidth, panelHeight, borderColor, fillColor)

	x = x + spacing * 1.5
	y = y + spacing

	for i = 1, #groups do
		local group = groups[i]

		draw.SimpleText(group.Name, "HudDefault", x, y, Color(0, 255, 0))

		y = y + textHeight

		self:DrawHealthBar(x, y, barWidth, barHeight, self["GetDamageGroup" .. i](self) / group.MaxHealth)

		y = y + barHeight + spacing
	end
end

function ENT:HUDPaint()
	self.HUDData = {
		Left = margin,
		Right = ScrW() - margin,
		Top = margin,
		Bottom = ScrH() - margin
	}

	self:PaintHUDHealth()
end

local block = {
	CHudHealth = true
}

function ENT:HUDShouldDraw(name)
	if block[name] then
		return false
	end
end

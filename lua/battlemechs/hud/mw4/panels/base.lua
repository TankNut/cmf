local PANEL = {}
local HUD = battlemechs.HUDList.mw4

AccessorFunc(PANEL, "_Mech", "Mech")

function PANEL:Init()
	self:SetSkin("Battlemechs_MW4")

	self:SetSize(ScrW(), ScrH())
	self:ParentToHUD()

	print(self)

	--self:Add(HUD.Panels.Health)
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Panel", self, w, h)
end

HUD.BasePanel = vgui.RegisterTable(PANEL, "Panel")

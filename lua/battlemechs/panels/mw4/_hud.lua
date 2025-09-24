local PANEL = {}

AccessorFunc(PANEL, "_Mech", "Mech")

function PANEL:Init()
	self:SetSkin("Battlemechs_MW4")

	self:SetSize(ScrW(), ScrH())
	self:ParentToHUD()
end

function PANEL:Think()
	local ent = self._Mech

	if not IsValid(ent) or ent:GetDriver() != LocalPlayer() then
		self:Remove()

		return
	end
end

vgui.Register("DBattlemechs_HUD_MW4", PANEL, "Panel")

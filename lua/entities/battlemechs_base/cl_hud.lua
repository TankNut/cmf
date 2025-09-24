function ENT:HUDPaint()
	if not IsValid(self.HUD) and self:GetDriver() == LocalPlayer() then
		self.HUD = vgui.Create("DBattlemechs_HUD_MW4")
		self.HUD:SetMech(self)
	end
end

local block = {
	CHudHealth = true
}

function ENT:HUDShouldDraw(name)
	if block[name] and self:GetDriver() == LocalPlayer() then
		return false
	end
end

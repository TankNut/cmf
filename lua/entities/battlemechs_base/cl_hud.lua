function ENT:InitHUD()
	self.ActiveHUD = battlemechs.HUDList.mw4
	self.ActiveHUD:Init()
end

function ENT:DestroyHUD()
	if self.ActiveHUD then
		self.ActiveHUD:Destroy()
		self.ActiveHUD = nil
	end
end

function ENT:UpdateHUD()
	local isDriving = self:GetDriver() == LocalPlayer()

	if isDriving and not self.ActiveHUD then
		self:InitHUD()
	elseif not isDriving and self.ActiveHUD then
		self:DestroyHUD()
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

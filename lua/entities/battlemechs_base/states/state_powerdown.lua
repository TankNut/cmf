AddCSLuaFile()

local function shutdownDone(self)
	self:SetState(battlemechs.STATE_OFFLINE)
end

local function getPowerState(self)
	return 1 - self:GetStateFraction()
end

ENT.States[battlemechs.STATE_POWERDOWN] = {
	AllowMovement = false,
	PowerState = getPowerState,
	OnTimer = shutdownDone
}

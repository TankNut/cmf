AddCSLuaFile()

local function startupDone(self)
	self:SetState(battlemechs.STATE_ONLINE)
end

local function getPowerState(self)
	return self:GetStateFraction()
end

ENT.States[battlemechs.STATE_POWERUP] = {
	AllowMovement = false,
	PowerState = getPowerState,
	OnTimer = startupDone
}

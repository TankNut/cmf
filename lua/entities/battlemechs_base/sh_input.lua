AddCSLuaFile()

if CLIENT then
	return
end

function ENT:CanPowerDown()
	return true--self.MoveData.Velocity:Length2D() < 50
end

function ENT:TogglePower()
	local state = self:GetActiveState()

	if state == battlemechs.STATE_OFFLINE then
		self:SetState(battlemechs.STATE_POWERUP, CurTime() + 1)
	elseif state == battlemechs.STATE_ONLINE and self:CanPowerDown() then
		self:SetState(battlemechs.STATE_POWERDOWN, CurTime() + 1)
	end
end

function ENT:PlayerButtonDown(ply, button)
	if button == KEY_I then
		self:TogglePower()
	end
end

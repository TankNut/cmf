AddCSLuaFile()

function ENT:GetState()
	return self.States[self:GetActiveState()]
end

function ENT:GetStateVar(name)
	local tab = self:GetState()

	if tab and tab[name] then
		return tab[name]
	end
end

function ENT:CallStateVar(name, ...)
	local val = self:GetStateVar(name)

	return isfunction(val) and val(self, ...) or val
end

function ENT:SetState(state, time)
	self:SetActiveState(state)

	self:SetStateSwitchTime(CurTime())
	self:SetStateTimer(time or 0)

	self:CallStateVar("SwitchTo")
end

function ENT:GetStateFraction()
	local time = self:GetStateTimer()

	if time == 0 then
		return 1
	end

	return math.Clamp(math.TimeFraction(self:GetStateSwitchTime(), time, CurTime()), 0, 1)
end

function ENT:UpdateState()
	local time = self:GetStateTimer()

	if time != 0 and time <= CurTime() then
		self:SetStateTimer(0)
		self:CallStateVar("OnTimer")
	end
end

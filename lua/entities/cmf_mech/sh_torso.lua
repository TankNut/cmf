AddCSLuaFile()

function ENT:InitTorso()
	self.LastTorsoUpdate = CurTime()
end

local function approachAngle(from, to, delta, mins, maxs)
	if mins == 0 and maxs == 0 then
		return math.ApproachAngle(from, to, delta)
	end

	from = math.NormalizeAngle(from)
	to = math.NormalizeAngle(to)

	local diff = math.AngleDifference(to, from)

	if from + diff < mins or from + diff > maxs then
		diff = -diff
	end

	return math.Approach(from, from + diff, delta)
end

function ENT:UpdateTorso()
	local delta = CurTime() - self.LastTorsoUpdate

	local ang = self:GetTorsoAngle()
	local ply = self:GetDriver()

	local target = angle_zero
	local mins, maxs = self.TorsoRange[1], self.TorsoRange[2]

	local pitchRate, yawRate

	if isangle(self.TorsoTurnRate) then
		pitchRate, yawRate = self.TorsoTurnRate.p, self.TorsoTurnRate.y
	else
		pitchRate, yawRate = self.TorsoTurnRate, self.TorsoTurnRate
	end

	if IsValid(ply) then
		target = ply:LocalEyeAngles() - self:GetAngles()

		if mins.p != 0 and mins.y != 0 then
			target.p = math.Clamp(math.NormalizeAngle(target.p), mins.p, maxs.p)
		end

		if mins.y != 0 and maxs.y != 0 then
			target.y = math.Clamp(math.NormalizeAngle(target.y), mins.y, maxs.y)
		end
	end

	if pitchRate == 0 then
		ang.p = target.p
	else
		ang.p = approachAngle(ang.p, target.p, pitchRate * delta, mins.p, maxs.p)
	end

	if yawRate == 0 then
		ang.y = target.y
	else
		ang.y = approachAngle(ang.y, target.y, yawRate * delta, mins.y, maxs.y)
	end

	self:SetTorsoAngle(ang)

	self.LastTorsoUpdate = CurTime()
end

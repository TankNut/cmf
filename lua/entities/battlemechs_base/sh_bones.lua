AddCSLuaFile()

function ENT:InitBones()
	self.Bones = {}
	self.HitboxBones = {}

	self.LastBoneThink = CurTime()

	self:AddBone("Root", {
		Callback = self.UpdateRootBone
	})

	self:BuildBones()
end

function ENT:UpdateRootBone(bone)
	bone.Ang = self:GetAngles()

	local offset = self:GetGaitOffset()
	offset:Rotate(bone.Ang)

	bone.Pos = self:GetPos()
	bone.Pos:Add(offset)
end

function ENT:GetBone(name)
	if name then
		return self.Bones[name]
	end
end

local updatedBones

function ENT:UpdateBone(bone)
	if updatedBones[bone.Name] then
		return
	end

	local parent = self:GetBone(bone.Parent)

	if parent then
		self:UpdateBone(parent)

		if bone.Offset then
			local offset = bone.Offset

			bone.Pos, bone.Ang = LocalToWorld(offset.Pos or vector_origin, offset.Ang or angle_zero, parent.Pos, parent.Ang)
		else
			bone.Pos = parent.Pos
			bone.Ang = parent.Ang
		end
	end

	if bone.Turret then
		self:UpdateTurret(bone)
	end

	if bone.Callback then
		bone.Callback(self, bone)
	end

	updatedBones[bone.Name] = true
end

local function approachAngle(from, to, delta, range)
	if not istable(range) then
		return math.ApproachAngle(from, to, delta)
	end

	from = math.NormalizeAngle(from)
	to = math.NormalizeAngle(to)

	local diff = math.AngleDifference(to, from)

	if from + diff < range[1] or from + diff > range[2] then
		diff = -diff
	end

	return math.Approach(from, from + diff, delta)
end

function ENT:GetTurretAngle(bone, config, ang, forwardAngle)
	if config.Callback then
		return config.Callback(self, bone)
	else
		if self:CanAim(bone, config) then
			if config.Torso and self:ShouldLockTorso() then
				return ang + forwardAngle
			else
				local target = (self.BoneTrace.HitPos - bone.Pos):Angle()
				target:Normalize()

				return target
			end
		else
			return forwardAngle
		end
	end
end

function ENT:UpdateTurret(bone)
	local parent = self:GetBone(bone.Parent)
	local config = bone.Turret

	local ang = self["Get" .. config.NetworkVar](self)
	local forwardAngle

	if parent then
		forwardAngle = parent.Ang
	else
		forwardAngle = self:GetAngles()
	end

	if not config.Slave then
		local targetAngle = self:GetTurretAngle(bone, config, ang, forwardAngle)

		-- Turn range
		local pitchRange = config.Pitch
		local yawRange = config.Yaw

		local relTargetAngle = targetAngle - forwardAngle

		if istable(pitchRange) then
			relTargetAngle.p = math.Clamp(math.NormalizeAngle(relTargetAngle.p), pitchRange[1], pitchRange[2])
		elseif isnumber(pitchRange) then
			relTargetAngle.p = pitchRange
		end

		if istable(yawRange) then
			relTargetAngle.y = math.Clamp(math.NormalizeAngle(relTargetAngle.y), yawRange[1], yawRange[2])
		elseif isnumber(yawRange) then
			relTargetAngle.y = yawRange
		end

		-- Turn rate
		local rate = config.Rate or 0
		local pitchRate, yawRate

		if isangle(config.Rate) then
			pitchRate, yawRate = rate.p, rate.y
		else
			pitchRate, yawRate = rate, rate
		end

		local delta = self.BoneDelta

		if pitchRate == 0 then
			ang.p = relTargetAngle.p
		else
			ang.p = approachAngle(ang.p, relTargetAngle.p, pitchRate * delta, pitchRange)
		end

		if yawRate == 0 then
			ang.y = relTargetAngle.y
		else
			ang.y = approachAngle(ang.y, relTargetAngle.y, yawRate * delta, yawRange)
		end

		self["Set" .. config.NetworkVar](self, ang)
	end

	if config.NoPitch then
		ang.p = 0
	end

	if config.NoYaw then
		ang.y = 0
	end

	bone.Ang = ang + forwardAngle
end

function ENT:UpdateBones()
	self.BoneDelta = CurTime() - self.LastBoneThink
	self.BoneTrace = self:GetAimTrace()

	updatedBones = {}

	for _, bone in pairs(self.Bones) do
		self:UpdateBone(bone)
	end

	self.LastBoneThink = CurTime()
end

function ENT:AddBone(name, data)
	assert(not self.Bones[name], string.format("A bone with the name '%s' already exists!", name))

	data = data or {}
	data.Name = name
	data.Pos = Vector()
	data.Ang = Angle()

	self.Bones[name] = data
	self.HitboxBones[name] = {}
end

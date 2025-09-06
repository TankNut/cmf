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
		local targetAngle

		if config.Callback then
			targetAngle = config.Callback(self, bone)
		else
			local ply = self:GetDriver()

			-- Todo: Change this
			targetAngle = IsValid(ply) and ply:LocalEyeAngles() or self:GetAngles()

			if IsValid(ply) and ply:KeyDown(IN_WALK) and bone.Name == "Torso" then
				targetAngle = ang + forwardAngle
			end
		end

		-- Turn range
		local range = config.Range or 0
		local mins, maxs

		if istable(range) then
			mins, maxs = range[1], config.Range[2]
		elseif isangle(range) then
			mins, maxs = -range, range
		else
			mins = Angle(-range, -range)
			maxs = Angle(range, range)
		end

		-- Turn rate
		local rate = config.Rate or 0
		local pitchRate, yawRate

		if isangle(config.Rate) then
			pitchRate, yawRate = rate.p, rate.y
		else
			pitchRate, yawRate = rate, rate
		end

		local relTargetAngle = targetAngle - forwardAngle

		if mins.p != 0 and maxs.p != 0 then
			relTargetAngle.p = math.Clamp(math.NormalizeAngle(relTargetAngle.p), mins.p, maxs.p)
		end

		if mins.y != 0 and maxs.y != 0 then
			relTargetAngle.y = math.Clamp(math.NormalizeAngle(relTargetAngle.y), mins.y, maxs.y)
		end

		local delta = self.BoneDelta

		if pitchRate == 0 then
			ang.p = relTargetAngle.p
		else
			ang.p = approachAngle(ang.p, relTargetAngle.p, pitchRate * delta, mins.p, maxs.p)
		end

		if yawRate == 0 then
			ang.y = relTargetAngle.y
		else
			ang.y = approachAngle(ang.y, relTargetAngle.y, pitchRate * delta, mins.y, maxs.y)
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

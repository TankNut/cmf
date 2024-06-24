AddCSLuaFile()

function ENT:CreateBone(name)
	local bone = {
		Name = name,
		Pos = Vector(),
		Ang = Angle(),
		LastUpdate = FrameNumber(),
		Blueprint = self.Blueprint.Bones[name]
	}

	self.Bones[name] = bone
end

function ENT:LoadBones()
	-- Built-in bones
	self:CreateBone("root")

	self:CreateBone("lhip")
	self:CreateBone("lknee")
	self:CreateBone("lfoot")

	self:CreateBone("rhip")
	self:CreateBone("rknee")
	self:CreateBone("rfoot")

	for name in pairs(self.Blueprint.Bones) do
		if not self.Bones[name] then
			self:CreateBone(name)
		end
	end
end

function ENT:UpdateBone(bone, frame)
	if bone.LastUpdate == frame then
		return
	end

	local blueprint = bone.Blueprint

	local originPos = self:GetPos()
	local originAng = self:GetAngles()

	local offsetPos = Vector()
	local offsetAng = Angle()

	if blueprint then
		local parent = self.Bones[blueprint.Parent]

		if parent then
			self:UpdateBone(parent, frame)

			originPos = parent.Pos
			originAng = parent.Ang
		end

		offsetPos = blueprint.Offset
		offsetAng = blueprint.Angle

		if blueprint.Callback != "" then
			cmf:RunBoneCallback(self, bone, originPos, originAng)

			bone.LastUpdate = frame

			return
		end
	end

	bone.Pos, bone.Ang = LocalToWorld(offsetPos, offsetAng, originPos, originAng)
	bone.LastUpdate = frame
end

function ENT:UpdateBones()
	local frame = FrameNumber()

	for _, bone in pairs(self.Bones) do
		self:UpdateBone(bone, frame)
	end
end

function ENT:GetRootBoneOffset()
	local vel = self:GetVelocity()
	local fraction = self:GetMoveFraction()
	local cycle = self:GetWalkCycle()

	local length = vel:Length2D()

	local pos = Vector()
	local ang = Angle()

	do -- Walkcycle bob
		local offset = 0.1

		local magnitude = math.Remap(length, 0, 530, 15, 10)
		local radians = math.Remap((cycle + offset) % 1, 0, 0.5, -math.pi, math.pi)

		pos.z = pos.z + math.sin(radians) * magnitude * fraction
	end

	-- Sideways velocity roll
	ang.r = ang.r + math.Remap(vel:Dot(-self:GetRight()), -530, 530, -15, 15)

	do -- Walkcycle roll
		local offset = 0.125

		local magnitude = math.Remap(length, 0, 530, 5, 10)
		local radians = math.Remap((cycle + offset) % 1, 0, 1, -math.pi, math.pi)

		ang.r = ang.r + math.sin(radians) * magnitude * fraction
	end

	return pos, ang
end

if CLIENT then
	local forward = Color(255, 0, 0)
	local right = Color(0, 255, 0)
	local up = Color(0, 0, 255)

	local tree = Color(191, 127, 255)

	local length = 10

	function ENT:DrawBones()
		local blueprints = self.Blueprint.Bones

		for name, bone in pairs(self.Bones) do
			local pos = bone.Pos
			local ang = bone.Ang

			render.DrawLine(pos, pos + ang:Forward() * length, forward)
			render.DrawLine(pos, pos + ang:Right() * length, right)
			render.DrawLine(pos, pos + ang:Up() * length, up)

			local blueprint = blueprints[name]

			if blueprint and blueprint.Parent != "" then
				render.DrawLine(pos, self.Bones[blueprint.Parent].Pos, tree)
			end
		end
	end
end

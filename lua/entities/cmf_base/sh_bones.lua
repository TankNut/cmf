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

if CLIENT then
	local forward = Color(255, 0, 0)
	local right = Color(0, 255, 0)
	local up = Color(0, 0, 255)

	local tree = Color(191, 127, 255)

	local length = 10

	function ENT:DrawBones()
		for name, bone in pairs(self.Bones) do
			local pos = bone.Pos
			local ang = bone.Ang

			render.DrawLine(pos, pos + ang:Forward() * length, forward)
			render.DrawLine(pos, pos + ang:Right() * length, right)
			render.DrawLine(pos, pos + ang:Up() * length, up)

			if bone.Blueprint and bone.Blueprint.Parent != "" then
				render.DrawLine(pos, self.Bones[bone.Blueprint.Parent].Pos, tree)
			end
		end
	end
end

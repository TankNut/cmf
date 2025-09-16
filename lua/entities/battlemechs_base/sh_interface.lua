AddCSLuaFile()

function ENT:CreateNetworkVars()
end

function ENT:BuildBones()
end

function ENT:UpdateRootBone(bone)
	local offset = self:GetGaitOffset()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	offset:Rotate(self:GetAngles())
	pos:Add(offset)

	bone.Pos = pos
	bone.Ang = ang
end

function ENT:BuildLegs()
end

function ENT:OnStepStart(index, leg)
end

function ENT:OnStepFinish(index, leg)
	if SERVER then
		sound.Play(")sfx_footfall_generic.wav", leg.Pos, 100, math.Rand(95, 105))
	end
end

if CLIENT then
	function ENT:BuildModel()
		for _, v in ipairs(self.ModelData) do
			self:AddPart(v)
		end
	end
else
	function ENT:BuildHitboxes()
	end
end

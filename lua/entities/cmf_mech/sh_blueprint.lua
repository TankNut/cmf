AddCSLuaFile()

-- Functions that are designed to be overwritten

function ENT:BuildBones()
end

function ENT:UpdateRootBone(bone)
	bone.Ang = self:GetAngles()

	local offset = self:GetGaitOffset()
	offset:Rotate(bone.Ang)

	bone.Pos = self:GetPos()
	bone.Pos:Add(offset)
end

function ENT:BuildLegs()
end

function ENT:OnStepStart(index, leg)
end

function ENT:OnStepFinish(index, leg)
	if SERVER then
		self:EmitSound(")sfx_footfall_generic.wav", 100, math.Rand(95, 105))
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

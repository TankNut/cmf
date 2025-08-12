AddCSLuaFile()

-- All of your custom functions can be found here

function ENT:BuildBones()
end

function ENT:UpdateBones()
end

function ENT:BuildLegs()
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

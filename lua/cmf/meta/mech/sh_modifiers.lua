AddCSLuaFile()

local meta = cmf:Class("Mech")

function meta:AddModifier(modifier, bone)
	assert(self.Modifiers[bone])

	table.insert(self.Modifiers[bone], modifier)
end

function meta:ApplyModifier(bone, modifier)
end

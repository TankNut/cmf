AddCSLuaFile()

cmf.Modifiers = cmf.Modifiers or {}

function cmf:RegisterModifier(name, callback)
	self.Modifiers[name] = callback
end

cmf:RegisterModifier("Test/Test", function() end)

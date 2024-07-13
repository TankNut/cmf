AddCSLuaFile()

cmf.Meta = cmf.Meta or {}

function cmf:Class(name)
	if not self.Meta[name] then
		local class = {}

		class.__index = class

		self.Meta[name] = class
	end

	return self.Meta[name]
end

function cmf:Instance(name, ...)
	local instance = setmetatable({}, self.Meta[name])

	if instance.Initialize then
		instance:Initialize(...)
	end

	return instance
end

AddCSLuaFile()

if not cmf.Meta.Hitbox then
	cmf.Meta.Hitbox = {}
	cmf.Meta.Hitbox.__index = cmf.Meta.Hitbox
end

local meta = cmf.Meta.Hitbox
local fields = {
	Bone = "root",

	Offset = Vector(),
	Angle = Angle(),

	Size = Vector()
}

function meta:Initialize()
	for key, value in pairs(fields) do
		local typeid = TypeID(value)

		if typeid == TYPE_VECTOR then
			value = Vector(value)
		elseif typeid == TYPE_ANGLE then
			value = Angle(value)
		end

		self[key] = value
	end
end

function meta:GetMinimized()
	local copy = {}

	for key, value in pairs(self) do
		local default = fields[key]

		if default != nil and value != default then
			copy[key] = value
		end
	end

	return copy
end

function meta:Load(tab)
	for key, value in pairs(tab) do
		if TypeID(value) == TypeID(fields[key]) then
			self[key] = value
		end
	end
end

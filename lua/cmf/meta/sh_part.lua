AddCSLuaFile()

if not cmf.Meta.Part then
	cmf.Meta.Part = {}
	cmf.Meta.Part.__index = cmf.Meta.Part
end

local meta = cmf.Meta.Part
local fields = {
	Bone = "root",

	Model = "models/props_lab/cactus.mdl",
	Skin = 0,

	Offset = Vector(),
	Angle = Angle()
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

function meta:Load(tbl)
	for key, value in pairs(tbl) do
		if TypeID(value) == TypeID(fields[key]) then
			self[key] = value
		end
	end
end

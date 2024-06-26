AddCSLuaFile()

if not cmf.Meta.Bone then
	cmf.Meta.Bone = {}
	cmf.Meta.Bone.__index = cmf.Meta.Bone
end

local meta = cmf.Meta.Bone
local fields = {
	Parent = "",
	Callback = "",

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

function meta:Load(tab)
	for key, value in pairs(tab) do
		if TypeID(value) == TypeID(fields[key]) then
			self[key] = value
		end
	end
end

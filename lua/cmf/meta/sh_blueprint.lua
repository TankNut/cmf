AddCSLuaFile()

if not cmf.Meta.Blueprint then
	cmf.Meta.Blueprint = {}
	cmf.Meta.Blueprint.__index = cmf.Meta.Blueprint
end

local meta = cmf.Meta.Blueprint
local fields = {
	Name = "Unnamed Mech",
	Author = "Unknown",
	Revision = 1,

	-- Movement
	StandHeight = 0,
	TurnRate = 90,
	RunSpeed = 530,
	WalkSpeed = 200,
	Acceleration = 400,

	-- Legs
	LegSpacing = 0,
	UpperLegLength = 0,
	LowerLegLength = 0,
	FootOffset = 0,

	-- Physics
	PhysboxMins = Vector(),
	PhysboxMaxs = Vector()
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

	self.Bones = {}
	self.Hitboxes = {}
	self.Parts = {}
end

-- Get minimized version for storage
-- Works by copying everything, then nilling out any fields that are identical to their defaultX counterparts
-- There's probably a better way to do this, some kind of recursive validator with a type whitelist but things can always be refactored later
function meta:GetMinimized()
	local copy = {}

	for key, value in pairs(self) do
		local default = fields[key]

		if default != nil and value != default then
			copy[key] = value
		end
	end

	copy.Bones = {}
	copy.Hitboxes = {}
	copy.Parts = {}

	for index, bone in pairs(self.Bones) do
		copy.Bones[index] = bone:GetMinimized()
	end

	for index, hitbox in pairs(self.Hitboxes) do
		copy.Hitboxes[index] = hitbox:GetMinimized()
	end

	for index, part in pairs(self.Parts) do
		copy.Parts[index] = part:GetMinimized()
	end

	return copy
end

function meta:CreateBone(name)
	local bone = setmetatable({}, cmf.Meta.Bone)

	self.Bones[name] = bone
	bone:Initialize()

	return bone
end

function meta:AddHitbox()
	local hitbox = setmetatable({}, cmf.Meta.Hitbox)

	table.insert(self.Hitboxes, hitbox)
	hitbox:Initialize()

	return hitbox
end

function meta:AddPart()
	local part = setmetatable({}, cmf.Meta.Part)

	table.insert(self.Parts, part)
	part:Initialize()

	return part
end

-- Save/load

function meta:Save(path)
	file.CreateDir(string.GetPathFromFilename(path))
	file.Write(path, util.TableToJSON(self:GetMinimized(), true))
end

function meta:Load(tbl)
	for key, value in pairs(tbl) do
		if TypeID(value) == TypeID(fields[key]) then
			self[key] = value
		end
	end

	if tbl.Bones then
		for name, data in pairs(tbl.Bones) do
			local bone = self:CreateBone(name)

			bone:Load(data)
		end
	end

	if tbl.Hitboxes then
		for _, data in pairs(tbl.Hitboxes) do
			local hitbox = self:AddHitbox()

			hitbox:Load(data)
		end
	end

	if tbl.Parts then
		for _, data in pairs(tbl.Parts) do
			local part = self:AddPart()

			part:Load(data)
		end
	end
end

-- Creation

function cmf:Blueprint()
	local blueprint = setmetatable({}, meta)

	blueprint:Initialize()

	return blueprint
end

function cmf:LoadBlueprint(path)
	if not file.Exists(path, "DATA") then
		return
	end

	local loaded = util.JSONToTable(file.Read(path, "DATA"))
	local blueprint = self:Blueprint()

	blueprint:Load(loaded)

	return blueprint
end

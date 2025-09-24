AddCSLuaFile()

local function recursiveAddFile(path)
	local files, folders = file.Find(path .. "*", "LUA")

	for _, filename in ipairs(files) do
		if string.GetExtensionFromFilename(filename) != "lua" then
			continue
		end

		AddCSLuaFile(path .. filename)
	end

	for _, folder in ipairs(folders) do
		recursiveAddFile(path .. folder .. "/")
	end
end

local _, huds = file.Find("battlemechs/hud/*", "LUA")

for _, path in ipairs(huds) do
	recursiveAddFile("battlemechs/hud/" .. path .. "/")
end

if SERVER then
	return
end

battlemechs.HUDList = battlemechs.HUDList or {}

include("hud/mw4/_hud.lua")

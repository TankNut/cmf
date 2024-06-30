AddCSLuaFile()

include("sh_edit.lua")

cmf:IncludeClient("properties/prop_angle.lua")
cmf:IncludeClient("properties/prop_bones.lua")
cmf:IncludeClient("properties/prop_int.lua")
cmf:IncludeClient("properties/prop_vector.lua")

if SERVER then
	return
end

function cmf:OpenEditor(pos, force)
	if not cmf.Editor then
		cmf.Editor = {
			Blueprint = cmf:Blueprint()
		}
	end

	cmf.Editor.Origin = pos

	if force then
		cmf.Editor.Blueprint = cmf:Blueprint()
	end

	local panel = vgui.Create("cmf_editor")
	panel.Blueprint = cmf.Editor.Blueprint
	panel:PopulateTree()

	cmf.Editor.Panel = panel
end

local PANEL = {}

function PANEL:Init()
	self:SetSize(ScreenScale(75), ScreenScale(150))

	self.Menu = self:Add("DMenuBar")
	self.Menu:DockMargin(-3, -6, -3, 0)
	self.Menu:Dock(TOP)
	self.Menu:AddMenu("File")

	self.Tree = self:Add("DTree")
	self.Tree:DockMargin(-3, 0, -3, -3)
	self.Tree:Dock(FILL)

	self:MakePopup()
	self:Center()
end

function PANEL:OpenNode(title, object, fields, context)
	local edit = vgui.Create("cmf_edit")

	edit:Setup(title, object, fields, context)
end

function PANEL:AddGeneralNode(title, icon, fields)
	self.General:AddNode(title, icon).Label.DoDoubleClick = function()
		self:OpenNode(title, self.Blueprint, fields)
		return true
	end
end

function PANEL:AddSubNode(parent, name, title, icon, object, fields, context)
	local node = parent:AddNode(name, icon)

	node.Label.DoDoubleClick = function()
		self:OpenNode(title, object, fields, context)
		return true
	end

	return node
end

local boneFields = {
	Parent = {order = 0, title = "Parent", type = "CMF_Bones"},
	Offset = {order = 1, title = "Offset", type = "CMF_Vector"},
	Angle = {order = 2, title = "Angle", type = "CMF_Angle"}
}

local defaultBones = {
	["root"] = true,
	["lhip"] = true,
	["lknee"] = true,
	["lfoot"] = true,
	["rhip"] = true,
	["rknee"] = true,
	["rfoot"] = true
}

function PANEL:PopulateBones(expand)
	self.Bones:Clear()

	for name, bone in SortedPairs(self.Blueprint.Bones) do
		local node = self:AddSubNode(self.Bones, name, "Bone: " .. name, "icon16/connect.png", bone, boneFields, {
			IsBone = true,
			Name = name,
			Bone = bone,
			DefaultBones = defaultBones
		})

		node.DoRightClick = function()
			local context = DermaMenu()
			context:AddOption("Delete Bone", function()
				self.Blueprint:RemoveBone(name)
				self:PopulateBones(true)
			end):SetIcon("icon16/delete.png")

			context:Open()
		end
	end

	if expand then
		self.Bones:SetExpanded(true)
	end
end

function PANEL:CreateBoneNode()
	self.Bones = self.RootNode:AddNode("Bones", "icon16/folder.png")
	self.Bones.DoRightClick = function()
		local blueprint = self.Blueprint
		local context = DermaMenu()

		context:AddOption("Add Bone...", function()
			Derma_StringRequest("Add Bone", "Choose a name for the newly added bone", "", function(name)
				if name == "" then
					return
				end

				if blueprint.Bones[name] then
					Derma_Message("Specified bone already exists", "Error", "Ok")

					return
				end

				blueprint:AddBone(name)

				self:PopulateBones(true)
			end)
		end):SetIcon("icon16/add.png")

		local sub, parent = context:AddSubMenu("Add Default Bone...")
		parent:SetIcon("icon16/table.png")

		for name in pairs(defaultBones) do
			if blueprint.Bones[name] then
				continue
			end

			sub:AddOption(name, function()
				if blueprint.Bones[name] then
					return
				end

				blueprint:AddBone(name)

				self:PopulateBones(true)
			end)
		end

		context:Open()

		return true
	end

	self:PopulateBones()
end

local informationFields = {
	Name = {order = 0, title = "Name", type = "Generic"},
	Version = {order = 1, title = "Version", type = "Generic"},
	Author = {order = 2, title = "Author", type = "Generic"}
}

local movementFields = {
	WalkSpeed = {order = 1, title = "Walk Speed", type = "CMF_Int"},
	RunSpeed = {order = 2, title = "Run Speed", type = "CMF_Int"},
	Acceleration = {order = 3, title = "Acceleration", type = "CMF_Int"},
	TurnRate = {order = 4, title = "Turn Rate", type = "CMF_Int"}
}

local gaitFields = {
	StandHeight = {order = 0, title = "Standing Height", type = "CMF_Int"},
	LegSpacing = {order = 1, title = "Leg Spacing", type = "CMF_Int"},
	UpperLegLength = {order = 2, title = "Upper Leg Length", type = "CMF_Int"},
	LowerLegLength = {order = 3, title = "Lower Leg Length", type = "CMF_Int"},
	FootOffset = {order = 4, title = "Foot Offset", type = "CMF_Int"}
}

local physicsFields = {
	PhysboxMins = {order = 0, title = "Physics Mins", type = "CMF_Vector"},
	PhysboxMaxs = {order = 1, title = "Physics Maxs", type = "CMF_Vector"}
}

function PANEL:PopulateTree()
	if self.RootNode then
		self.RootNode:Remove()
	end

	self.RootNode = self.Tree:AddNode("*unsaved*", "icon16/page.png")
	self.General = self.RootNode:AddNode("General", "icon16/computer.png")

	self:AddGeneralNode("Information", "icon16/page_white_text.png", informationFields)
	self:AddGeneralNode("Movement", "icon16/joystick.png", movementFields)
	self:AddGeneralNode("Gait", "icon16/chart_line.png", gaitFields)
	self:AddGeneralNode("Physics", "icon16/shape_handles.png", physicsFields)

	self:CreateBoneNode()

	local hitboxes = self.RootNode:AddNode("Hitboxes", "icon16/folder.png")

	hitboxes.DoRightClick = function()
		local context = DermaMenu()

		context:AddOption("Add Hitbox...")
		context:Open()

		return true
	end

	local parts = self.RootNode:AddNode("Parts", "icon16/folder.png")

	parts.DoRightClick = function()
		local context = DermaMenu()

		context:AddOption("Add Part...")
		context:Open()

		return true
	end

	self.RootNode:SetExpanded(true)
end

vgui.Register("cmf_editor", PANEL, "DFrame")

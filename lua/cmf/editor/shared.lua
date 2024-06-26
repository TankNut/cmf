AddCSLuaFile()

include("sh_edit.lua")

if SERVER then
	return
end

function cmf:OpenEditor(pos)
	cmf.Editor = {
		Origin = pos,
		Panel = vgui.Create("cmf_editor"),
		Blueprint = cmf:Blueprint()
	}
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

	self:PopulateTree()

	self:MakePopup()
	self:Center()
end

function PANEL:OpenBlueprintNode(title, fields)
	local edit = vgui.Create("cmf_edit")

	edit:Setup(title, cmf.Editor.Blueprint, fields)
end

local informationFields = {
	Name = {order = 0, title = "Name", type = "Generic"},
	Version = {order = 1, title = "Version", type = "Generic"},
	Author = {order = 2, title = "Author", type = "Generic"}
}

function PANEL:AddBlueprintNode(node, title, icon, fields)
	node:AddNode(title, icon).Label.DoDoubleClick = function()
		self:OpenBlueprintNode(title, fields)
		return true
	end
end

function PANEL:PopulateTree()
	if self.RootNode then
		self.RootNode:Remove()
	end

	self.RootNode = self.Tree:AddNode("*unsaved*", "icon16/page.png")

	local general = self.RootNode:AddNode("General", "icon16/computer.png")

	self:AddBlueprintNode(general, "Information", "icon16/page_white_text.png", informationFields)
	general:AddNode("Movement", "icon16/joystick.png")
	general:AddNode("Gait", "icon16/chart_line.png")
	general:AddNode("Physics", "icon16/shape_handles.png")

	local bones = self.RootNode:AddNode("Bones", "icon16/folder.png")
	bones:AddNode("root", "icon16/connect.png")
	bones:AddNode("torso", "icon16/connect.png")
	bones:AddNode("weapons", "icon16/connect.png")
	bones:AddNode("Add...", "icon16/add.png")

	local hitboxes = self.RootNode:AddNode("Hitboxes", "icon16/folder.png")
	hitboxes:AddNode("Add...", "icon16/add.png")

	local parts = self.RootNode:AddNode("Parts", "icon16/folder.png")
	parts:AddNode("Add...", "icon16/add.png")

	self.RootNode:SetExpanded(true)
end

vgui.Register("cmf_editor", PANEL, "DFrame")

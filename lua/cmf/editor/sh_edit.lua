AddCSLuaFile()

if SERVER then
	return
end

local PANEL = {}

function PANEL:Setup(tab, fields, context)
	self.Table = tab
	self.Fields = fields
	self.Context = context

	self:Rebuild()
end

function PANEL:Rebuild()
	self:Clear()

	for key, data in SortedPairsByMemberValue(self.Fields, "order") do
		self:AddVar(key, data)
	end
end

function PANEL:AddVar(key, data)
	local row = self:CreateRow(data.category or "General", data.title)

	data.context = self.Context or {}

	row:Setup(data.type, data)

	row.DataUpdate = function()
		row:SetValue(self.Table[key])
	end

	row.DataChanged = function(_, val)
		self.Table[key] = val
	end
end

vgui.Register("cmf_properties", PANEL, "DProperties")

PANEL = {}

function PANEL:Init()
	self:SetSize(ScreenScale(100), ScreenScale(150))

	self.Props = self:Add("cmf_properties")
	self.Props:Dock(FILL)

	self:MakePopup()
	self:Center()
end

function PANEL:Setup(title, tab, fields, context)
	self:SetTitle(title)
	self.Props:Setup(tab, fields, context)
end

vgui.Register("cmf_edit", PANEL, "DFrame")

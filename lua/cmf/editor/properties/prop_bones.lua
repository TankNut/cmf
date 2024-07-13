local PANEL = {}

function PANEL:Init()
end

function PANEL:Setup(vars)
	self:Clear()

	local combo = self:Add("DComboBox")

	combo:DockMargin(0, 1, 2, 2)
	combo:Dock(FILL)

	local context = vars.context

	if context.IsBone then
		combo:AddChoice("*none*", "")
	end

	if context.IsBone and cmf.DefaultBones[context.Name] then
		combo:SetTooltip("Built-in bones cannot have a parent set.")
	else
		local boneList = cmf.Editor.Mech.Bones
		local bones = {}

		for name, bone in pairs(boneList) do
			if context.IsBone and context.Name == name then
				continue
			end

			bones[name] = true
		end

		for name in pairs(cmf.DefaultBones) do
			if boneList[name] then
				continue
			end

			bones[name] = true
		end

		for name in SortedPairs(bones) do
			combo:AddChoice(name, name)
		end
	end

	self.IsEditing = function()
		return combo:IsMenuOpen()
	end

	self.SetValue = function(_, val)
		for id, data in pairs(combo.Data) do
			if data == val then
				combo:ChooseOptionID(id)
			end
		end
	end

	combo.OnSelect = function(_, id, val, data)
		self:ValueChanged(data, true)
	end

	combo.Paint = function(pnl, w, h)
		if self:IsEditing() or self:GetRow():IsHovered() or self:GetRow():IsChildHovered() then
			DComboBox.Paint(pnl, w, h)
		end
	end

	self:GetRow().AddChoice = function(_, value, data, select)
		combo:AddChoice(value, data, select)
	end

	self:GetRow().SetSelected = function(_, id)
		combo:ChooseOptionID(id)
	end

	self.IsEnabled = function()
		return combo:IsEnabled()
	end

	self.SetEnabled = function(_, b)
		combo:SetEnabled(b)
	end
end

vgui.Register("DProperty_CMF_Bones", PANEL, "DProperty_Generic")

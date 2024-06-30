local PANEL = {}

function PANEL:Init()
end

function PANEL:Setup(vars)
	self:Clear()

	local text = self:Add("DTextEntry")

	text:SetPaintBackground(false)
	text:Dock(FILL)

	self.IsEditing = function()
		return text:IsEditing()
	end

	self.IsEnabled = function()
		return text:IsEnabled()
	end

	self.SetEnabled = function(_, b)
		text:SetEnabled(b)
	end

	self.SetValue = function(_, val)
		text:SetText(string.format("%.2f %.2f %.2f", val.p, val.y, val.r))
	end

	text.OnValueChange = function(_, val)
		self:ValueChanged(Angle(val))
	end
end

vgui.Register("DProperty_CMF_Angle", PANEL, "DProperty_Generic")

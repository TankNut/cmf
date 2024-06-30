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
		text:SetText(val)
	end

	text.OnValueChange = function(_, val)
		val = tonumber(val)

		if val != nil then
			self:ValueChanged(val)
		end
	end

	local abs = false -- Absolute values only

	if vars then
		abs = vars.abs
	end

	text.AllowInput = function(_, char)
		if not abs and char == "-" then
			return false
		end

		return not string.find(char, "%d")
	end
end

vgui.Register("DProperty_CMF_Int", PANEL, "DProperty_Generic")

local HUD = {}
battlemechs.HUDList.mw4 = HUD

include("_skin.lua")
include("panels/base.lua")

function HUD:Init(mech)
	self.Instance = vgui.CreateFromTable(self.BasePanel)
	self.Instance:SetMech(mech)
end

function HUD:Destroy()
	if IsValid(self.Instance) then
		self.Instance:Remove()
		self.Instance = nil
	end
end

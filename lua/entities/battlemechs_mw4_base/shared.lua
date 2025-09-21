AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_base")

ENT.Base = "battlemechs_base"

local i = 0
local function addSkin(category, name)
	local tab = {
		Name = name,
		Category = category,
		Material = i == 0 and "default" or "skin" .. i
	}

	i = i + 1

	return tab
end

ENT.Skins = {
	addSkin(nil, "None"),

	addSkin("Ops", "Blue"),
	addSkin("Ops", "Red"),
	addSkin("Ops", "Gold"),
	addSkin("Ops", "Green"),
	addSkin("Ops", "Orange")
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", "SkinIndex")

	BaseClass.SetupDataTables(self)
end

function ENT:CanProperty(ply, prop)
	return prop != "skin"
end

properties.Add("battlemechs_mw4_skin", {
	MenuLabel = "Skin",
	Order = 601,
	MenuIcon = "icon16/picture_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) then return false end
		if not scripted_ents.IsBasedOn(ent:GetClass(), "battlemechs_mw4_base") then return false end
		if not hook.Run("CanProperty", ply, "battlemechs_mw4_skin", ent) then return false end

		return #ent.Skins > 0
	end,

	MenuOpen = function(self, option, ent, tr)
		local submenu = option:AddSubMenu()
		local categories = {}

		local current = ent:GetSkinIndex()

		for k, v in ipairs(ent.Skins) do
			local index = k - 1
			local target = submenu

			if v.Category then
				if not categories[v.Category] then
					categories[v.Category] = submenu:AddSubMenu(v.Category)
				end

				target = categories[v.Category]
			end

			local choice = target:AddOption(v.Name)
			choice:SetRadio(true)
			choice:SetChecked(current == index)
			choice:SetIsCheckable(true)

			choice.OnChecked = function(_, checked)
				if checked then
					self:SetSkin(ent, index)
				end
			end
		end
	end,

	Action = function(self, ent) end,

	SetSkin = function(self, ent, index)
		self:MsgStart()
			net.WriteEntity(ent)
			net.WriteUInt(index, 8)
		self:MsgEnd()
	end,

	Receive = function(self, length, ply)
		local ent = net.ReadEntity()
		local index = net.ReadUInt(8)

		if not properties.CanBeTargeted(ent, ply) then return end
		if not self:Filter(ent, ply) then return end

		ent:SetSkinIndex(index)
	end
})

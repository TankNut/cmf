AddCSLuaFile()
DEFINE_BASECLASS("battlemechs_base")

ENT.Base = "battlemechs_base"

include("sh_skins.lua")

function ENT:SetupDataTables()
	self:NetworkVar("Int", "SkinIndex")

	BaseClass.SetupDataTables(self)
end

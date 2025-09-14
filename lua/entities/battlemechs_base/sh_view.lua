AddCSLuaFile()

if SERVER then
	function ENT:SetThirdPersonMode(ply)
		local mode = tobool(ply:GetInfoNum("battlemechs_thirdperson", 1))

		self.Seat:SetThirdPersonMode(mode)
	end

	return
end

function ENT:UpdateThirdPerson()
	local ply = self:GetDriver()

	if ply != LocalPlayer() then
		return
	end

	local mode = self:GetSeat():GetThirdPersonMode() and 1 or 0

	if mode != ply:GetInfoNum("battlemechs_thirdperson", 1) then
		RunConsoleCommand("battlemechs_thirdperson", mode)
	end
end

function ENT:CalcView(ply, origin, angles, fov, znear, zfar)
	if ply:GetViewEntity() != ply then
		return
	end

	self:UpdateBones()

	origin, angles = self:GetViewOrigin()

	return {
		origin = origin,
		angles = angles,
		fov = fov,
		znear = znear,
		zfar = zfar,
		drawviewer = self:GetSeat():GetThirdPersonMode()
	}
end

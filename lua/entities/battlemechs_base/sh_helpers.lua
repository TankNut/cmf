AddCSLuaFile()

function ENT:GetMoveVelocity()
	if CLIENT then
		return self:GetMechVelocity()
	else
		return self.MoveData.Velocity
	end
end

function ENT:GetMoveStat(val)
	local scale = math.Clamp(math.Remap(self:GetMoveVelocity():Length2D(), self.WalkSpeed, self.RunSpeed, 0, 1), 0, 1)

	if istable(val) then
		return Lerp(scale, val[1], val[2])
	elseif isfunction(val) then
		return val(self, scale)
	end

	return val
end

function ENT:BoneToWorld(name, pos, ang)
	local bone = self:GetBone(name)

	return LocalToWorld(pos or vector_origin, ang or angle_zero, bone.Pos, bone.Ang)
end

function ENT:GetViewOrigin()
	local ply = self:GetDriver()
	local ang = IsValid(ply) and ply:LocalEyeAngles() or self:GetAngles()

	local thirdperson = self:GetSeat():GetThirdPersonMode()

	if thirdperson then
		local config = self.ThirdPersonSettings
		local origin = LocalToWorld(config.Pos, angle_zero, self:GetPos(), ang)

		local tr = util.TraceHull({
			start = origin,
			endpos = origin + (ang:Forward() * -config.Distance),
			mask = MASK_SOLID,
			filter = self,
			mins = Vector(-4, -4, -4),
			maxs = Vector(4, 4, 4),
		})

		return tr.HitPos, ang
	else
		local config = self.FirstPersonSettings

		return config.Bone and self:BoneToWorld(config.Bone, config.Pos) or self:LocalToWorld(config.Pos), ang
	end
end

function ENT:GetAimTrace()
	local ply = self:GetDriver()

	if not IsValid(ply) then
		return
	end
end

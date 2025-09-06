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

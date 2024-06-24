AddCSLuaFile()

local rad2Deg = 180 / math.pi

local function acos(rad)
	return math.deg(math.acos(rad))
end

local function toLocalAxis(ent, axis)
	return ent:WorldToLocal(axis + ent:GetPos())
end

local function bearing(originPos, originAngle, pos)
	pos = WorldToLocal(pos, angle_zero, originPos, originAngle)

	return rad2Deg * -math.atan2(pos.y, pos.x)
end

local function localToWorldAngles(localAng, origin)
	local _, ang = LocalToWorld(vector_origin, localAng, vector_origin, origin)

	return ang
end

function ENT:InitLegs()
	self.LastGaitUpdate = CurTime()
	self.Legs = {
		[self.LEG_LEFT] = {
			CycleOffset = 0,
			Offset = 1,
			Hip = self.Bones.lhip,
			Knee = self.Bones.lknee,
			Foot = self.Bones.lfoot
		},
		[self.LEG_RIGHT] = {
			CycleOffset = 0.5,
			Offset = -1,
			Hip = self.Bones.rhip,
			Knee = self.Bones.rknee,
			Foot = self.Bones.rfoot
		}
	}
end

function ENT:PerformLegIK(index, leg)
	local blueprint = self.Blueprint
	local target = leg.Pos
	local targetNormal = leg.Normal

	local length1 = blueprint.UpperLegLength
	local length2 = blueprint.LowerLegLength

	if leg.Moving then
		length2 = length2 + blueprint.FootOffset
	else
		target = target + targetNormal * blueprint.FootOffset
	end

	local rootBone = self.Bones.root

	local hipPos = LocalToWorld(Vector(0, blueprint.LegSpacing * leg.Offset, 0), angle_zero, rootBone.Pos, rootBone.Ang)
	local axis = toLocalAxis(self, target - hipPos)
	local dist = math.min(axis:Length(), length1 + length2)

	local axisAngle = axis:Angle()

	axisAngle.r = -bearing(hipPos, self:GetAngles(), target)
	axisAngle:RotateAroundAxis(axisAngle:Right(), 180 - acos(
		(dist^2 + length1^2 - length2^2) / (2 * length1 * dist)))

	local hipAng = self:LocalToWorldAngles(axisAngle)

	hipAng:RotateAroundAxis(hipAng:Right(), 180)

	local upperCosine = acos((length2^2 + length1^2 - dist^2) / (2 * length1 * length2))

	local kneeAng = localToWorldAngles(Angle(upperCosine - 180, 0, 0), hipAng)
	local kneePos = hipPos + hipAng:Forward() * length1

	local footAng

	if leg.Moving then
		footAng = localToWorldAngles(Angle(-90, 0, 0), kneeAng)
	else
		footAng = targetNormal:Angle()

		footAng:RotateAroundAxis(footAng:Right(), -90)
		footAng:RotateAroundAxis(targetNormal, -footAng.y + self:GetAngles().y)
	end

	local footPos = kneePos + kneeAng:Forward() * blueprint.LowerLegLength - footAng:Up() * blueprint.FootOffset

	local offset = Vector(0, 1, 0)

	if index == 1 then
		offset.y = -offset.y
	end

	offset:Rotate(self:GetAngles())

	leg.Hip.Pos = hipPos
	leg.Hip.Ang = hipAng

	leg.Knee.Pos = kneePos
	leg.Knee.Ang = kneeAng

	leg.Foot.Pos = footPos
	leg.Foot.Ang = footAng
end

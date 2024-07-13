AddCSLuaFile()

local meta = cmf:Class("Mech")
local rad2Deg = 180 / math.pi

local function acos(rad)
	return math.deg(math.acos(rad))
end

local function toLocalAxis(ent, axis)
	return ent:WorldToLocal(axis + ent.Position)
end

local function bearing(originPos, originAngle, pos)
	pos = WorldToLocal(pos, angle_zero, originPos, originAngle)

	return rad2Deg * -math.atan2(pos.y, pos.x)
end

local function localToWorldAngles(localAng, origin)
	local _, ang = LocalToWorld(vector_origin, localAng, vector_origin, origin)

	return ang
end

function meta:PerformLegIK(index, leg)
	local target = leg.Pos
	local targetNormal = leg.Normal

	local length1 = self.UpperLegLength
	local length2 = self.LowerLegLength

	if leg.Moving then
		length2 = length2 + self.FootOffset
	else
		target = target + targetNormal * self.FootOffset
	end

	local rootBone = self.Bones.root
	local ang = self.Angle

	local hipPos = LocalToWorld(Vector(0, self.LegSpacing * leg.Offset, 0), angle_zero, rootBone.Position, rootBone.Angle)
	local axis = toLocalAxis(self, target - hipPos)
	local dist = math.min(axis:Length(), length1 + length2)

	local axisAngle = axis:Angle()

	axisAngle.r = -bearing(hipPos, ang, target)
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
		footAng:RotateAroundAxis(targetNormal, -footAng.y + ang.y)
	end

	local footPos = kneePos + kneeAng:Forward() * self.LowerLegLength - footAng:Up() * self.FootOffset

	local offset = Vector(0, 1, 0)

	if index == 1 then
		offset.y = -offset.y
	end

	offset:Rotate(ang)

	local frame = FrameNumber()

	leg.Hip.Position = hipPos
	leg.Hip.Angle = hipAng
	leg.Hip.LastUpdate = frame

	leg.Knee.Position = kneePos
	leg.Knee.Angle = kneeAng
	leg.Knee.LastUpdate = frame

	leg.Foot.Position = footPos
	leg.Foot.Angle = footAng
	leg.Foot.LastUpdate = frame
end

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
			Hip = self.Bones.LHip,
			Knee = self.Bones.LKnee,
			Foot = self.Bones.LFoot
		},
		[self.LEG_RIGHT] = {
			CycleOffset = 0.5,
			Offset = -1,
			Hip = self.Bones.RHip,
			Knee = self.Bones.RKnee,
			Foot = self.Bones.RFoot
		}
	}
end

function ENT:PerformLegIK(index, leg)
	local target = leg.Pos
	local targetNormal = leg.Normal

	local length1, length2 = self.UpperLength, self.LowerLength

	if leg.Moving then
		length2 = length2 + self.FootOffset
	else
		target = target + targetNormal * self.FootOffset
	end

	local rootBone = self.Bones[""]

	local hipPos = LocalToWorld(Vector(0, self.LegSpacing * leg.Offset, 0), angle_zero, rootBone.Pos, rootBone.Ang)
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

	local footPos = kneePos + kneeAng:Forward() * self.LowerLength - footAng:Up() * self.FootOffset

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

if CLIENT then
	local forward = Color(255, 0, 0)
	local right = Color(0, 255, 0)
	local up = Color(0, 0, 255)

	local length = 10

	function ENT:DrawLegs()
		for k, leg in pairs(self.Legs) do
			render.DrawLine(leg.Hip.Pos, leg.Hip.Pos + leg.Hip.Ang:Forward() * self.UpperLength, forward)
			render.DrawLine(leg.Hip.Pos, leg.Hip.Pos + leg.Hip.Ang:Right() * length, right)
			render.DrawLine(leg.Hip.Pos, leg.Hip.Pos + leg.Hip.Ang:Up() * length, up)

			render.DrawLine(leg.Knee.Pos, leg.Knee.Pos + leg.Knee.Ang:Forward() * self.LowerLength, forward)
			render.DrawLine(leg.Knee.Pos, leg.Knee.Pos + leg.Knee.Ang:Right() * length, right)
			render.DrawLine(leg.Knee.Pos, leg.Knee.Pos + leg.Knee.Ang:Up() * length, up)

			render.DrawLine(leg.Foot.Pos, leg.Foot.Pos + leg.Foot.Ang:Forward() * length, forward)
			render.DrawLine(leg.Foot.Pos, leg.Foot.Pos + leg.Foot.Ang:Right() * length, right)
			render.DrawLine(leg.Foot.Pos, leg.Foot.Pos + leg.Foot.Ang:Up() * length, up)
		end
	end
end

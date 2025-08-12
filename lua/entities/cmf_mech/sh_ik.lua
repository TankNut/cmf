AddCSLuaFile()

local function toWorldAng(bone, ang)
	return select(2, LocalToWorld(vector_origin, ang, bone.Pos, bone.Ang))
end

local function toLocalAxis(bone, axis)
	local pos = WorldToLocal(axis + bone.Pos, angle_zero, bone.Pos, bone.Ang)

	return pos
end

local function atan2(a, b)
	return math.deg(math.atan2(a, b))
end

local function icos(a, b, c)
	return math.deg(math.acos((a^2 + b^2 - c^2) / (2 * a * b)))
end

function ENT:IK_2Seg_Humanoid(leg)
	local pos, ang = LocalToWorld(leg.Origin, leg.Rotation, leg.RootBone.Pos, leg.RootBone.Ang)

	local base = {
		Pos = pos,
		Ang = ang
	}

	local target = leg.Pos

	if leg.Foot then
		leg.Foot.Pos = leg.Pos

		local footAxis = toLocalAxis(base, leg.Normal)
		leg.Foot.Ang = toWorldAng(base, Angle(-atan2(footAxis.z, footAxis.x) + 90, 0, atan2(footAxis.z, footAxis.y) - 90))

		target = target + leg.Foot.Ang:Up() * leg.FootOffset
	end

	local localAxis = toLocalAxis(base, target - base.Pos)
	local temp = {Pos = Vector(base.Pos), Ang = toWorldAng(base, Angle(0, 0, atan2(localAxis.z, localAxis.y) + 90))}

	localAxis = toLocalAxis(temp, target - base.Pos)
	local distance = math.min(localAxis:Length(), leg.LengthA + leg.LengthB)

	leg.Hip.Pos = LocalToWorld(leg.Origin, angle_zero, leg.RootBone.Pos, leg.RootBone.Ang)

	if leg.Chicken then
		local pitch = atan2(localAxis.x, localAxis.z) + icos(distance, leg.LengthA, leg.LengthB)

		leg.Hip.Ang = toWorldAng(temp, Angle(pitch - 90, 0, 0))
		leg.Knee.Ang = toWorldAng(leg.Hip, Angle(icos(leg.LengthB, leg.LengthA, distance) + 180, 0, 0))
	else
		local pitch = atan2(-localAxis.x, localAxis.z) + icos(distance, leg.LengthA, leg.LengthB)

		leg.Hip.Ang = toWorldAng(temp, Angle(pitch - 90, 180, 180))
		leg.Knee.Ang = toWorldAng(leg.Hip, Angle(icos(leg.LengthB, leg.LengthA, distance), 180, 180))
	end

	leg.Knee.Pos = leg.Hip.Pos + leg.Hip.Ang:Forward() * leg.LengthA
end

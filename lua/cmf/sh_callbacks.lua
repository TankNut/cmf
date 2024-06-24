AddCSLuaFile()

local rootMovement = function(ent, bone, originPos, originAng)
	local pos, ang = ent:GetRootBoneOffset()

	bone.Pos, bone.Ang = LocalToWorld(pos, ang, originPos, originAng)
end

local torsoCallback = function(ent, bone, originPos, originAng)
	local blueprint = bone.Blueprint
	local ply = ent:GetDriver()

	bone.Pos = LocalToWorld(blueprint.Offset, angle_zero, originPos, originAng)

	if IsValid(ply) then
		local eyeAng = ply:LocalEyeAngles()
		eyeAng.p = 0
		eyeAng.r = 0

		bone.Ang = eyeAng
	else
		bone.Ang = originAng
	end
end

local weaponCallback = function(ent, bone, originPos, originAng)
	local blueprint = bone.Blueprint
	local ply = ent:GetDriver()

	bone.Pos = LocalToWorld(blueprint.Offset, angle_zero, originPos, originAng)

	if IsValid(ply) then
		local eyeAng = ply:LocalEyeAngles()
		eyeAng.r = 0

		bone.Ang = eyeAng
	else
		bone.Ang = originAng
	end
end

local callbacks = {
	["builtin/root"] = rootMovement,
	["builtin/torso/yaw_only"] = torsoCallback,
	["builtin/weapons/pitch_yaw"] = weaponCallback
}

function cmf:RunBoneCallback(ent, bone, originPos, originAng)
	local blueprint = bone.Blueprint
	local callback = callbacks[blueprint.Callback]

	callback(ent, bone, originPos, originAng)
end

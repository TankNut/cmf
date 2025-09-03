AddCSLuaFile()

if CLIENT then
	return
end

function ENT:BuildHitboxes()
	self:AddHitbox("Torso", Vector(-75, 0, 35), Angle(0, 0, 0), Vector(160, 80, 110))
	self:AddHitbox("Torso", Vector(-30, 0, 23), Angle(0, 0, 0), Vector(15, 120, 15))

	self:AddHitbox("LWeapon", Vector(-52, 12.5, -5), Angle(0, 0, 0), Vector(110, 25, 40))
	self:AddHitbox("RWeapon", Vector(-52, -12.5, -5), Angle(0, 0, 0), Vector(110, -25, 40))

	self:AddHitbox("LHip", Vector(-13, 0, 2), Angle(0, 0, 0), Vector(90, 13, 35))
	self:AddHitbox("LKnee", Vector(-35, -2, -28),  Angle(-17, 0, 0), Vector(80, 20, 15))
	self:AddHitbox("LKnee", Vector(30, -2, -7),  Angle(-17, 0, 0), Vector(45, 40, 35))

	self:AddHitbox("LFoot", Vector(0, 0, 0),  Angle(-90, 0, 0), Vector(17, 43, 48))
	self:AddHitbox("LFoot", Vector(15.5, -13, 8.5),  Angle(0, -45, 0), Vector(32, 23, 17))
	self:AddHitbox("LFoot", Vector(15.5, 13, 8.5),  Angle(0, 45, 0), Vector(32, 23, 17))
	self:AddHitbox("LFoot", Vector(-39, 0, 0),  Angle(-90, 0, 0), Vector(17, 20, 31))

	self:AddHitbox("RHip", Vector(-13, 0, 2), Angle(0, 0, 0), Vector(90, 13, 35))
	self:AddHitbox("RKnee", Vector(-35, 2, -28), Angle(-17, 0, 0), Vector(80, 20, 15))
	self:AddHitbox("RKnee", Vector(30, 2, -7), Angle(-17, 0, 0), Vector(45, 40, 35))

	self:AddHitbox("RFoot", Vector(0, 0, 0),  Angle(-90, 0, 0), Vector(17, 43, 48))
	self:AddHitbox("RFoot", Vector(15.5, 13, 8.5), Angle(0, 45, 0), Vector(32, 23, 17))
	self:AddHitbox("RFoot", Vector(15.5, -13, 8.5), Angle(0, -45, 0), Vector(32, 23, 17))
	self:AddHitbox("RFoot", Vector(-39, 0, 0), Angle(-90, 0, 0), Vector(17, 20, 31))
end

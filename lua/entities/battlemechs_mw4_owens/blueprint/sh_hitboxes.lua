AddCSLuaFile()

if CLIENT then
	return
end

function ENT:BuildHitboxes()
	self:AddHitbox("Torso", Vector(-30, 0, -5), Angle(0, 0, 0),   Vector(120, 60, 38))
	self:AddHitbox("Torso", Vector(2.5, 0, -5), Angle(-90, 0, 0), Vector(55, 40, 40))
	self:AddHitbox("Torso", Vector(-20, 0, 13), Angle(0, 0, 0),   Vector(40, 100, 15))

	self:AddHitbox("LeftWeapon", Vector(-28, 65, 1),  Angle(0, 0, -90), Vector(60, 47, 30))
	self:AddHitbox("RightWeapon", Vector(-28, -65, 1), Angle(0, 0, 90),  Vector(60, 47, 30))

	self:AddHitbox("LHip",  Vector(-13, -12, 5), Angle(0, 0, 0),   Vector(self.UpperLength + 25, 13, 30))
	self:AddHitbox("LKnee", Vector(-10, 0, -5),  Angle(-10, 0, 0), Vector(self.LowerLength + 10, 20, 30))
	self:AddHitbox("LFoot", Vector(2, 2, 0),     Angle(-90, 0, 0), Vector(self.FootOffset, 40, 55))

	self:AddHitbox("RHip",  Vector(-13, 12.5, 5), Angle(0, 0, 0),   Vector(self.UpperLength + 25, 13, 30))
	self:AddHitbox("RKnee", Vector(-10, 0, -5),   Angle(-10, 0, 0), Vector(self.LowerLength + 10, 20, 30))
	self:AddHitbox("RFoot", Vector(2, -2, 0),     Angle(-90, 0, 0), Vector(self.FootOffset, 40, 55))
end

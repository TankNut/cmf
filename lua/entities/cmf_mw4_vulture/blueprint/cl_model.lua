ENT.ModelData = {
	-- Hip
	cmf:ModelPart("models/mw4/vulture/vtr_hip.mdl",   "Root"),

	-- Torso
	cmf:ModelPart("models/mw4/vulture/vtr_torso.mdl", "Torso", {Pos = Vector(-10, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_specia.mdl", "Chin", {Pos = Vector(0, 0, 0.5)}),
	cmf:ModelPart("models/mw4/vulture/vtr_specia_left.mdl", "ChinGun", {Pos = Vector(0, 14, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_specia_right.mdl", "ChinGun", {Pos = Vector(0, -14, 0)}),

	-- Weapons
	cmf:ModelPart("models/mw4/vulture/vtr_lgun.mdl", "LeftWeapon"),
	cmf:ModelPart("models/mw4/vulture/vtr_rgun.mdl", "RightWeapon"),

	-- Left leg
	cmf:ModelPart("models/mw4/vulture/vtr_luleg.mdl", "LeftHip",  {Pos = Vector(0, -11, 0), Ang = Angle(-124, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_ldleg.mdl", "LeftKnee", {Ang = Angle(-62, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_lfoot.mdl", "LeftFoot", {Pos = Vector(0, 0, 33)}),

	-- Left foot
	cmf:ModelPart("models/mw4/vulture/vtr_litoe.mdl", "LeftFoot", {Pos = Vector(12.5, -11.25, 10.6), Ang = Angle(0, -45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_lotoe.mdl", "LeftFoot", {Pos = Vector(12.5,  11.25, 10.6), Ang = Angle(0,  45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_lbtoe.mdl", "LeftFoot", {Pos = Vector(-20,  0, 10.6), Ang = Angle(0,  0)}),

	-- Right leg
	cmf:ModelPart("models/mw4/vulture/vtr_ruleg.mdl", "RightHip",  {Pos = Vector(0, 11, 0), Ang = Angle(-124, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rdleg.mdl", "RightKnee", {Ang = Angle(-60, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rfoot.mdl", "RightFoot", {Pos = Vector(0, 0, 33)}),

	-- Right foot
	cmf:ModelPart("models/mw4/vulture/vtr_ritoe.mdl", "RightFoot", {Pos = Vector(12.5,  11.25, 10.6), Ang = Angle(0,  45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rotoe.mdl", "RightFoot", {Pos = Vector(12.5, -11.25, 10.6), Ang = Angle(0, -45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rbtoe.mdl", "RightFoot", {Pos = Vector(-20,  0, 10.6), Ang = Angle(0,  0)}),
}

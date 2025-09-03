ENT.ModelData = {
	-- Hip
	cmf:ModelPart("models/mw4/vulture/vtr_hip.mdl",   "Root"),

	-- Torso
	cmf:ModelPart("models/mw4/vulture/vtr_torso.mdl", "Torso", {Pos = Vector(-10, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_specia.mdl", "Torso", {Pos = Vector(70, 0, 15.5)}),
	cmf:ModelPart("models/mw4/vulture/vtr_specia_left.mdl", "Torso", {Pos = Vector(72, 14, 3.8)}),
	cmf:ModelPart("models/mw4/vulture/vtr_specia_right.mdl", "Torso", {Pos = Vector(72, -14, 3.8)}),

	-- Weapons
	cmf:ModelPart("models/mw4/vulture/vtr_lgun.mdl", "LWeapon"),
	cmf:ModelPart("models/mw4/vulture/vtr_rgun.mdl", "RWeapon"),

	-- Left leg
	cmf:ModelPart("models/mw4/vulture/vtr_luleg.mdl", "LHip",  {Pos = Vector(0, -11, 0), Ang = Angle(-124, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_ldleg.mdl", "LKnee", {Ang = Angle(-62, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_lfoot.mdl", "LFoot", {Pos = Vector(0, 0, 33)}),

	-- Left foot
	cmf:ModelPart("models/mw4/vulture/vtr_litoe.mdl", "LFoot", {Pos = Vector(12.5, -11.25, 10.6), Ang = Angle(0, -45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_lotoe.mdl", "LFoot", {Pos = Vector(12.5,  11.25, 10.6), Ang = Angle(0,  45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_lbtoe.mdl", "LFoot", {Pos = Vector(-20,  0, 10.6), Ang = Angle(0,  0)}),

	-- Right leg
	cmf:ModelPart("models/mw4/vulture/vtr_ruleg.mdl", "RHip",  {Pos = Vector(0, 11, 0), Ang = Angle(-124, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rdleg.mdl", "RKnee", {Ang = Angle(-60, 0, 0)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rfoot.mdl", "RFoot", {Pos = Vector(0, 0, 33)}),

	-- Right foot
	cmf:ModelPart("models/mw4/vulture/vtr_ritoe.mdl", "RFoot", {Pos = Vector(12.5,  11.25, 10.6), Ang = Angle(0,  45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rotoe.mdl", "RFoot", {Pos = Vector(12.5, -11.25, 10.6), Ang = Angle(0, -45)}),
	cmf:ModelPart("models/mw4/vulture/vtr_rbtoe.mdl", "RFoot", {Pos = Vector(-20,  0, 10.6), Ang = Angle(0,  0)}),
}

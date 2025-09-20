ENT.ModelData = {
	-- Hip
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_hip.mdl", "Root"),

	-- Torso
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_torso.mdl", "Torso"),

	-- Weapons
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_gun_left.mdl",  "LeftWeapon"),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_gun_right.mdl", "RightWeapon"),

	-- Left leg
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_upperleg_left.mdl",  "LHip",  {Pos = battlemechs:MW4Scale(0, -0.95, 0), Ang = Angle(-157, 0, 0)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_lowerleg_left.mdl",  "LKnee", {Pos = battlemechs:MW4Scale(0, 0, 0),     Ang = Angle(-60, 0, 0)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_foot_left.mdl",      "LFoot", {Pos = battlemechs:MW4Scale(0.1, 0.1, 0.8)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_toe_left_front.mdl", "LFoot", {Pos = battlemechs:MW4Scale(0.45, 0.1, 0.25)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_toe_left_back.mdl",  "LFoot", {Pos = battlemechs:MW4Scale(-0.54, 0.1, 0.25)}),

	-- Right leg
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_upperleg_right.mdl",  "RHip",  {Pos = battlemechs:MW4Scale(0, 0.95, 0), Ang = Angle(-157, 0, 0)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_lowerleg_right.mdl",  "RKnee", {Pos = battlemechs:MW4Scale(0, 0, 0),    Ang = Angle(-60, 0, 0)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_foot_right.mdl",      "RFoot", {Pos = battlemechs:MW4Scale(0.1, -0.1, 0.8)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_toe_right_front.mdl", "RFoot", {Pos = battlemechs:MW4Scale(0.45, -0.1, 0.25)}),
	battlemechs:ModelPart("models/battlemechs/mw4/owens/owens_toe_right_back.mdl",  "RFoot", {Pos = battlemechs:MW4Scale(-0.54, -0.1, 0.25)}),
}

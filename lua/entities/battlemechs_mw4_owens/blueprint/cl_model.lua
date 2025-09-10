ENT.ModelData = {
	-- Hip
	battlemechs:ModelPart("models/mw4addon/owens_hip.mdl", "Root"),

	-- Torso
	battlemechs:ModelPart("models/mw4addon/owens_torso.mdl", "Torso", {Pos = Vector(2, 0, 0)}),

	-- Weapons
	battlemechs:ModelPart("models/mw4addon/owens_lgun.mdl",  "Weapons", {Pos = Vector(0, 50, 0)}),
	battlemechs:ModelPart("models/mw4addon/owens_rgun.mdl",  "Weapons", {Pos = Vector(0, -50, 0)}),

	-- Left leg
	battlemechs:ModelPart("models/mw4addon/owens_luleg.mdl", "LHip",  {Pos = Vector(0, -23.5, 0), Ang = Angle(-157, 0, 0)}),
	battlemechs:ModelPart("models/mw4addon/owens_llleg.mdl", "LKnee", {Pos = Vector(0, -7, 0), Ang = Angle(-60, 0, 0)}),
	battlemechs:ModelPart("models/mw4addon/owens_lfoot.mdl", "LFoot", {Pos = Vector(0, 0, 13)}),

	-- Right leg
	battlemechs:ModelPart("models/mw4addon/owens_ruleg.mdl", "RHip",  {Pos = Vector(0, 24, 0), Ang = Angle(-157, 0, 0)}),
	battlemechs:ModelPart("models/mw4addon/owens_rlleg.mdl", "RKnee", {Pos = Vector(0, 8, 0), Ang = Angle(-60, 0, 0)}),
	battlemechs:ModelPart("models/mw4addon/owens_rfoot.mdl", "RFoot", {Pos = Vector(0, 0, 13)}),
}

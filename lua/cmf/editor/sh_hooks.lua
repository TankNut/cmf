local physColor = Color(255, 191, 0)

local function PostDrawOpaqueRenderables(panel, depth, skybox, skybox3d)
	if skybox or skybox3d then
		return
	end

	local mech = cmf.Editor.Mech
	local pos = cmf.Editor.Origin + Vector(0, 0, mech.StandHeight)

	render.DrawWireframeBox(pos, angle_zero, mech.PhysboxMins, mech.PhysboxMaxs, physColor)

	mech.Position = pos
	mech:Think()

	--mech:DrawBones()
end

function cmf:AddEditorHooks()
	hook.Add("PostDrawOpaqueRenderables", cmf.Editor.Panel, PostDrawOpaqueRenderables)
end

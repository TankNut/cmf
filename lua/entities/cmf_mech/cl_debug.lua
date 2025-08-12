local drawPhysics = CreateClientConVar("cmf_debug_physics", 0)
local drawBones = CreateClientConVar("cmf_debug_bones", 0)
local drawHitboxes = CreateClientConVar("cmf_debug_hitboxes", 0)
local drawGait = CreateClientConVar("cmf_debug_gait", 0)

local physicsColor = Color(255, 191, 0)
local hitboxColor =  Color(0, 161, 255)

local forward = Color(255, 0, 0)
local right =   Color(0, 255, 0)

local length = 10

function ENT:DrawDebug()
	if drawPhysics:GetBool()  then self:DrawPhysics() end
	if drawBones:GetBool()    then self:DrawBones() end
	if drawHitboxes:GetBool() then self:DrawHitboxes() end
	if drawGait:GetBool()     then self:DrawGait() end
end

function ENT:DrawPhysics()
	render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self.Hull.Mins, self.Hull.Maxs, physicsColor)
end

function ENT:DrawBones()
	for name, bone in pairs(self.Bones) do
		cmf:DrawWorldText(bone.Pos, name, true)
	end
end

function ENT:DrawHitboxes()
	for _, hitbox in pairs(self.Hitboxes) do
		render.DrawWireframeBox(hitbox:GetPos(), hitbox:GetAngles(), hitbox:GetHitboxMins(), hitbox:GetHitboxMaxs(), hitboxColor)
	end
end

function ENT:DrawGait()
	for _, leg in ipairs(self.Legs) do
		for k, pos in ipairs({leg.Ground, leg.Pos, leg.Target}) do
			local screen = pos:ToScreen()

			local r = k == 1 and 255 or 0
			local g = k == 2 and 255 or 0
			local b = k == 3 and 255 or 0

			if screen.visible then
				cam.Start2D()
					surface.DrawCircle(screen.x, screen.y, 10, r, g, b)
				cam.End2D()
			end
		end

		render.DrawLine(leg.Ground, leg.Ground + leg.OldNormal * length, forward)
		render.DrawLine(leg.Pos, leg.Pos + leg.Normal * length, right)
	end
end

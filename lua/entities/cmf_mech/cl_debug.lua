local drawPhysics = CreateClientConVar("cmf_debug_physics", 0)
local drawBones = CreateClientConVar("cmf_debug_bones", 0)
local drawHitboxes = CreateClientConVar("cmf_debug_hitboxes", 0)
local drawGait = CreateClientConVar("cmf_debug_gait", 0)
local drawIK = CreateClientConVar("cmf_debug_ik", 0)

local physicsColor = Color(255, 191, 0)

local forward = Color(255, 0, 0)
local right =   Color(0, 255, 0)
local up =      Color(0, 0, 255)

local length = 10

local function drawBox(pos, ang, mins, maxs, color)
	local oldAlpha = color.a

	color.a = 255
	render.DrawWireframeBox(pos, ang, mins, maxs, color)

	color.a = 10
	render.SetColorMaterial()
	cam.IgnoreZ(true)
	render.DrawBox(pos, ang, mins, maxs, color)
	cam.IgnoreZ(false)

	color.a = oldAlpha
end

function ENT:DrawDebug()
	if drawPhysics:GetBool()  then self:DrawPhysics() end
	if drawBones:GetBool()    then self:DrawBones() end
	if drawHitboxes:GetBool() then self:DrawHitboxes() end
	if drawGait:GetBool()     then self:DrawGait() end
	if drawIK:GetBool()       then self:DrawIK() end
end

function ENT:DrawPhysics()
	drawBox(self:GetPos(), self:GetAngles(), self.Hull.Mins, self.Hull.Maxs, physicsColor)
end

function ENT:DrawBones()
	for name, bone in pairs(self.Bones) do
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Forward() * 10, forward)
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Right() * 10, right)
		render.DrawLine(bone.Pos, bone.Pos + bone.Ang:Up() * 10, up)

		cmf:DrawWorldText(bone.Pos, name, true)
	end
end

function ENT:DrawHitboxes()
	if not self.Debug_HitboxCache then
		self.Debug_HitboxCache = {}

		local count = table.Count(self.HitboxBones)
		local increment = 360 / count

		for i = 0, count - 1 do
			table.insert(self.Debug_HitboxCache, HSVToColor(i * increment, 0.5, 1))
		end
	end

	local i = 1

	for index, group in pairs(self.HitboxBones) do
		local col = self.Debug_HitboxCache[i]

		for _, hitbox in ipairs(group) do
			drawBox(hitbox:GetPos(), hitbox:GetAngles(), hitbox:GetHitboxMins(), hitbox:GetHitboxMaxs(), col)
		end

		i = i + 1
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

		if leg.Ground and leg.OldNormal then
			render.DrawLine(leg.Ground, leg.Ground + leg.OldNormal * length, forward)
		end

		if leg.Pos and leg.Normal then
			render.DrawLine(leg.Pos, leg.Pos + leg.Normal * length, right)
		end
	end
end

function ENT:DrawIK()
	for _, leg in ipairs(self.Legs) do
		leg.Solver(self, leg, true)
	end
end

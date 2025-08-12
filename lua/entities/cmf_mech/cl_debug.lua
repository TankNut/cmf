local drawPhysics = CreateClientConVar("cmf_debug_physics", 0)
local drawBones = CreateClientConVar("cmf_debug_bones", 0)
local drawHitboxes = CreateClientConVar("cmf_debug_hitboxes", 0)
local drawLegs = CreateClientConVar("cmf_debug_legs", 0)
local drawGait = CreateClientConVar("cmf_debug_gait", 0)

local physicsColor = Color(255, 191, 0)
local hitboxColor =  Color(0, 161, 255)

local forward = Color(255, 0, 0)
local right =   Color(0, 255, 0)
local up =      Color(0, 0, 255)

local length = 10

function ENT:DrawDebug()
	if drawPhysics:GetBool()  then self:DrawPhysics() end
	if drawBones:GetBool()    then self:DrawBones() end
	if drawHitboxes:GetBool() then self:DrawHitboxes() end
	if drawLegs:GetBool()     then self:DrawLegs() end
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

function ENT:DrawLegs()
	for k, leg in ipairs(self.Legs) do
		render.DrawLine(leg.Hip.Pos, leg.Hip.Pos + leg.Hip.Ang:Forward() * self.UpperLength, forward)
		render.DrawLine(leg.Hip.Pos, leg.Hip.Pos + leg.Hip.Ang:Right()   * length,           right)
		render.DrawLine(leg.Hip.Pos, leg.Hip.Pos + leg.Hip.Ang:Up()      * length,           up)

		render.DrawLine(leg.Knee.Pos, leg.Knee.Pos + leg.Knee.Ang:Forward() * self.LowerLength, forward)
		render.DrawLine(leg.Knee.Pos, leg.Knee.Pos + leg.Knee.Ang:Right()   * length,           right)
		render.DrawLine(leg.Knee.Pos, leg.Knee.Pos + leg.Knee.Ang:Up()      * length,           up)

		render.DrawLine(leg.Foot.Pos, leg.Foot.Pos + leg.Foot.Ang:Forward() * length, forward)
		render.DrawLine(leg.Foot.Pos, leg.Foot.Pos + leg.Foot.Ang:Right()   * length, right)
		render.DrawLine(leg.Foot.Pos, leg.Foot.Pos + leg.Foot.Ang:Up()      * length, up)
	end
end

function ENT:DrawGait()
	for _, gait in ipairs(self.Gaits) do
		for k, pos in ipairs({gait.LastStep, gait.RealStep, gait.NextStep}) do
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
	end

	local screen = self.GlobalPos:ToScreen()

	if screen.visible then
		cam.Start2D()
			surface.DrawCircle(screen.x, screen.y, 10, 255, 255, 255)
		cam.End2D()
	end

	screen = self:GetPos():ToScreen()

	if screen.visible then
		cam.Start2D()
			local x, y = screen.x, screen.y
			local h = 0

			local function drawText(str, ...)
				local _, height = draw.SimpleText(string.format(str, ...), "BudgetLabel", x, y + h, color_white)

				h = h + height
			end

			drawText("Root Bone Offset: %.2f", self.GlobalPos:Distance(self:GetPos()))
			drawText("Fraction:         %.2f", self.GaitFraction)
		cam.End2D()
	end
end

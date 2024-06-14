AddCSLuaFile()

function ENT:InitMovement()
	if SERVER then
		self.MoveData = {
			LastUpdate = CurTime(),
			Velocity = Vector()
		}
	end
end

function ENT:GetMoveVelocity()
	if CLIENT then
		return self:GetMechVelocity()
	else
		return self.MoveData.Velocity
	end
end

function ENT:GetGroundOffset()
	return 110
end

function ENT:GetMoveAcceleration()
	return 400
end

function ENT:GetDesiredMoveSpeed(ply)
	return ply:KeyDown(IN_SPEED) and 530 or 200
end

function ENT:GetMoveFraction()
	return math.min(self:GetVelocity():Length2D() / 150, 1)
end

if SERVER then
	function ENT:CheckGround()
		local data = self.MoveData
		local vel = data.Velocity
		local tr = self:GetGroundTrace()

		data.GroundTrace = tr
		data.Slope = math.NormalizeAngle(tr.HitNormal:Angle().p + 90)

		local height = self:GetGroundOffset()
		local diff = height - tr.HitPos:Distance(tr.StartPos)

		data.OnGround = diff >= -(height * 0.5)

		if not data.OnGround then
			return
		end

		if data.Slope > 35 then
			local gravity = physenv.GetGravity().z * data.Delta
			local dir = Vector(tr.HitNormal)

			dir.x = dir.x * gravity
			dir.y = dir.y * gravity
			dir.z = 0

			vel:Sub(dir)
		end

		vel.z = diff * 10
	end

	function ENT:ApplyAirFriction()
		local vel = self.MoveData.Velocity
		local delta = self.MoveData.Delta

		vel.x = vel.x * (1 - 0.05 * delta)
		vel.y = vel.y * (1 - 0.05 * delta)
	end

	function ENT:GetDesiredVelocity()
		local ply = self.MoveData.Driver

		if not IsValid(ply) then
			return vector_origin
		end

		local forward = ply:KeyDown(IN_FORWARD) and 1 or 0
		local back = ply:KeyDown(IN_BACK) and 1 or 0

		local dir = Vector(forward - back, 0, 0)

		dir:Rotate(self:GetAngles())
		dir.z = 0
		dir:Normalize()

		return dir * self:GetDesiredMoveSpeed(ply)
	end

	function ENT:ApplyMoveInput()
		local data = self.MoveData
		local vel = data.Velocity

		local accel = 400 * data.Delta
		local target = self:GetDesiredVelocity()
		local dot = self:GetForward():Dot(data.GroundTrace.HitNormal)

		target = target + (target * dot)

		local ratio = (target - vel):GetNormalized()

		vel.x = math.Approach(vel.x, target.x, accel * ratio.x)
		vel.y = math.Approach(vel.y, target.y, accel * ratio.y)
	end

	function ENT:GetDesiredAngle()
		local data = self.MoveData

		local left = data.Driver:KeyDown(IN_MOVELEFT) and 1 or 0
		local right = data.Driver:KeyDown(IN_MOVERIGHT) and 1 or 0

		local direction = right - left

		return data.Yaw - (direction * self.TurnRate * data.Delta)
	end

	function ENT:PhysicsUpdate(phys)
		local data = self.MoveData

		data.Phys = phys
		data.Driver = self:GetDriver()
		data.HasDriver = IsValid(data.Driver)

		data.Delta = CurTime() - data.LastUpdate
		data.LastUpdate = CurTime()

		if phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
			return
		end

		phys:EnableGravity(true)

		data.Velocity = phys:GetVelocity()

		local dir = self:GetForward()
		dir.z = 0
		dir:Normalize()

		data.Yaw = math.NormalizeAngle(dir:Angle().y)

		self:CheckGround()

		if data.OnGround then
			self:ApplyMoveInput()
		else
			self:ApplyAirFriction()
		end

		if data.HasDriver then
			data.Yaw = self:GetDesiredAngle()
		end

		local turnAngle = -self:GetAngles() + Angle(0, data.Yaw, 0)

		self:SetMechVelocity(data.Velocity)

		phys:SetVelocity(data.Velocity)
		phys:SetAngleVelocity(Vector(turnAngle.r * 10, turnAngle.p * 10, turnAngle.y / data.Delta))
	end
end

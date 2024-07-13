AddCSLuaFile()

function ENT:LoadMech()
	self:InitPhysics()

	local mech = self.Mech

	mech.Entity = self

	if CLIENT then
		local radius = math.max(
			mech.UpperLegLength + mech.LowerLegLength + mech.FootOffset * 1.5,
			(mech.PhysboxMaxs - mech.PhysboxMins):Length() * 0.5
		)

		self:SetRenderBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))
	else
		self.MoveData = {
			LastUpdate = CurTime(),
			Velocity = Vector()
		}

		for _, hitbox in pairs(mech.Hitboxes) do
			self:CreateHitbox(hitbox.Bone, hitbox.Offset, hitbox.Angle, hitbox.Size)
		end
	end
end

if CLIENT then
	function ENT:RequestMech()
		net.Start("cmf_mech_request")
			net.WriteEntity(self)
		net.SendToServer()
	end

	net.Receive("cmf_mech_request", function()
		local ent = net.ReadEntity()
		local length = net.ReadUInt(16)
		local data = util.Decompress(net.ReadData(length))

		local mech = cmf:Instance("Mech")

		mech:Load(cmf:Decode(data))

		ent.Mech = mech
		ent:LoadMech()
	end)
else
	util.AddNetworkString("cmf_mech_request")

	function ENT:HandleMechRequest(ply)
		net.Start("cmf_mech_request")
			net.WriteEntity(self)
			net.WriteUInt(#self.DataCache, 16)
			net.WriteData(self.DataCache)
		net.Send(ply)
	end

	net.Receive("cmf_mech_request", function(_, ply)
		net.ReadEntity():HandleMechRequest(ply)
	end)
end

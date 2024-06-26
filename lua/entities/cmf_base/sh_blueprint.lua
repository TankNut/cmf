AddCSLuaFile()

function ENT:LoadBlueprint()
	self:InitPhysics()
	self:LoadBones()

	self:InitLegs()

	local blueprint = self.Blueprint

	if CLIENT then
		local radius = math.max(
			blueprint.UpperLegLength + blueprint.LowerLegLength + blueprint.FootOffset * 1.5,
			(blueprint.PhysboxMaxs - blueprint.PhysboxMins):Length() * 0.5
		)

		self:SetRenderBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))
	else
		self.MoveData = {
			LastUpdate = CurTime(),
			Velocity = Vector()
		}

		for _, hitbox in pairs(blueprint.Hitboxes) do
			self:CreateHitbox(hitbox.Bone, hitbox.Offset, hitbox.Angle, hitbox.Size)
		end
	end

	self.Loaded = true
end

if CLIENT then
	function ENT:RequestBlueprint()
		net.Start("cmf_blueprint_request")
			net.WriteEntity(self)
		net.SendToServer()
	end

	net.Receive("cmf_blueprint_request", function()
		local ent = net.ReadEntity()
		local length = net.ReadUInt(16)
		local data = util.Decompress(net.ReadData(length))

		ent.Blueprint = setmetatable(cmf:Decode(data), cmf.BlueprintMeta)
		ent:LoadBlueprint()
	end)
else
	util.AddNetworkString("cmf_blueprint_request")

	function ENT:HandleBlueprintRequest(ply)
		net.Start("cmf_blueprint_request")
			net.WriteEntity(self)
			net.WriteUInt(#self.BlueprintCache, 16)
			net.WriteData(self.BlueprintCache)
		net.Send(ply)
	end

	net.Receive("cmf_blueprint_request", function(_, ply)
		net.ReadEntity():HandleBlueprintRequest(ply)
	end)
end

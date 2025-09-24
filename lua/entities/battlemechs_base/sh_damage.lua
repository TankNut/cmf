AddCSLuaFile()

function ENT:InitDamageGroups()
	self.DamageGroups = {}
	self.DamageMap = {}

	self.DamagePool = 0

	self:BuildDamageGroups()

	for index, group in ipairs(self.DamageGroups) do
		local fraction = group.MaxHealth / self.DamagePool

		group.MaxHealth = fraction * self.BaseHealth

		self["SetDamageGroup" .. index](self, group.MaxHealth)
	end
end

function ENT:AddDamageGroup(name, health, bones)
	local index = table.insert(self.DamageGroups, {
		Name = name,
		MaxHealth = health
	})

	self.DamagePool = self.DamagePool + health

	self:NetworkVar("Int", "DamageGroup" .. index)

	for _, bone in ipairs(bones) do
		self.DamageMap[bone] = index
	end
end

function ENT:GetMechHealth(tab)
	if not tab then
		tab = {}
	end

	for i = 1, #self.DamageGroups do
		tab[i] = self["GetDamageGroup" .. i](self)
	end

	return tab
end

function ENT:GetTotalMechHealth()
	local health = 0

	for i = 1, #self.DamageGroups do
		health = health + self["GetDamageGroup" .. i](self)
	end

	return health
end

if SERVER then
	function ENT:TakeMechDamage(bone, dmg)
		local index = assert(self.DamageMap[bone], "Bone '" .. bone .. "' is not tied to a damage group!")
		local health = self["GetDamageGroup" .. index](self)

		local newHealth = math.ceil(health - dmg:GetDamage())

		if health == newHealth or health == 0 then
			return
		end

		self["SetDamageGroup" .. index](self, newHealth)
	end
end

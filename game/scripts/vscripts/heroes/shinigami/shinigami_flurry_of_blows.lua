shinigami_flurry_of_blows = class({})

function shinigami_flurry_of_blows:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_shinigami_flurry_of_blows_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_shinigami_flurry_of_blows_buff = class({})
LinkLuaModifier("modifier_shinigami_flurry_of_blows_buff", "heroes/shinigami/shinigami_flurry_of_blows.lua", 0)

function modifier_shinigami_flurry_of_blows_buff:OnCreated()
	self.attack_interval = 1 / self:GetAbility():GetTalentSpecialValueFor("attacks_per_second")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if IsServer() then
		self:StartIntervalThink(self.attack_interval)
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
	end
end

function modifier_shinigami_flurry_of_blows_buff:OnRefresh()
	self.attack_interval = 1 / self:GetAbility():GetTalentSpecialValueFor("attacks_per_second")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if IsServer() then 
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
	end
end

function modifier_shinigami_flurry_of_blows_buff:OnDestroy()
	if IsServer() then 
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_shinigami_flurry_of_blows_buff:OnIntervalThink()
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.7/self.attack_interval)
	local coneOrigin = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * self.radius
	local attackblur = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/jugg_arcana_crit_blur.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(attackblur, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(attackblur)
	local nearbyUnits = self:GetCaster():FindEnemyUnitsInRadius(coneOrigin, self.radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
	for _, unit in ipairs(nearbyUnits) do
		EmitSoundOn("Hero_PhantomAssassin.Attack", unit)
		EmitSoundOn("Hero_PhantomAssassin.Attack.Rip", unit)
		self:GetParent():PerformAbilityAttack(unit, true, self:GetAbility())
		local attack = ParticleManager:CreateParticle("particles/heroes/shinigami/shinigami_flurry_of_blows_striek.vpcf", PATTACH_POINT_FOLLOW, unit)
		ParticleManager:SetParticleControlEnt(attack, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(attack, 0, unit:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(attack)
	end
	--if #nearbyUnits == 0 then
		for i = 1, math.random(4) do
			local randomAttackPos = coneOrigin + RandomVector(math.random(self.radius))
			EmitSoundOnLocationWithCaster(randomAttackPos, "Hero_PhantomAssassin.Attack", self:GetParent())
			local randoParticle = math.random(100)
			if randoParticle > 0 and randoParticle <= 25 then
				local attack = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_blink.vpcf", PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(attack, 0, randomAttackPos)
				ParticleManager:ReleaseParticleIndex(attack)
			elseif randoParticle > 25 and randoParticle <= 50 then
				local attack = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_blinkb.vpcf", PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(attack, 0, randomAttackPos)
				ParticleManager:ReleaseParticleIndex(attack)
			elseif randoParticle > 50 and randoParticle <= 75 then
				local attack = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_blinkc.vpcf", PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(attack, 0, randomAttackPos)
				ParticleManager:ReleaseParticleIndex(attack)
			elseif randoParticle > 75 and randoParticle <= 100 then
				local attack = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_crit.vpcf", PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(attack, 0, randomAttackPos)
				ParticleManager:ReleaseParticleIndex(attack)
			end
			
		end
	--end
end

function modifier_shinigami_flurry_of_blows_buff:CheckState()
	local state = { [MODIFIER_STATE_DISARMED] = true}
	return state
end



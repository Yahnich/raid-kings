revenant_shadowscape = class({})
LinkLuaModifier( "modifier_shadowscape", "heroes/revenant/revenant_shadowscape.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadowscape_slow", "heroes/revenant/revenant_shadowscape.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadowscape_clone", "heroes/revenant/revenant_shadowscape.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_penumbra", "heroes/revenant/revenant_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_shadowscape:GetChannelTime()
	return self:GetSpecialValueFor("max_channel")
end

function revenant_shadowscape:GetChannelAnimation()
	return "ACT_DOTA_GENERIC_CHANNEL_1"
end

function revenant_shadowscape:GetChannelledManaCostPerSecond(iLevel)
	return self:GetManaCost(iLevel)
end

function revenant_shadowscape:OnSpellStart()
	self.caster = self:GetCaster()
	self.point = self.caster:GetAbsOrigin()

	self.radius = self:GetSpecialValueFor("radius")
	self.newRadius = 0

	EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Cast", self.caster)

	self.nfx = ParticleManager:CreateParticle("particles/heroes/revenant/revenant_shadowscape.vpcf", PATTACH_POINT, self.caster)
	ParticleManager:SetParticleControl(self.nfx, 0, self.point+Vector(0,0,100) )
	ParticleManager:SetParticleControl(self.nfx, 1, Vector(self.radius,self.radius,self.radius))

	self.caster:AddNewModifier(self.caster, self, "modifier_shadowscape", {})
end

function revenant_shadowscape:OnChannelThink(flInterval)
	ParticleManager:SetParticleControl(self.nfx, 1, Vector(self.radius+self.newRadius,self.radius+self.newRadius,self.radius+self.newRadius))
	self.newRadius = self.newRadius + 2
end

function revenant_shadowscape:OnChannelFinish(bInterrupted)
	ParticleManager:DestroyParticle(self.nfx, false)	
	self.caster:RemoveModifierByName("modifier_shadowscape")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_shadowscape = class({})

function modifier_shadowscape:OnCreated(table)
	self.radius = self:GetSpecialValueFor("radius")
	self:StartIntervalThink(FrameTime())
end

function modifier_shadowscape:OnIntervalThink()
	self.radius = self.radius + 2
end

function modifier_shadowscape:IsAura()
	return true
end

function modifier_shadowscape:GetAuraDuration()
	return self:GetSpecialValueFor("slow_duration")
end

function modifier_shadowscape:GetAuraEntityReject(hEntity)
	return hEntity == self:GetCaster()
end

function modifier_shadowscape:GetAuraRadius()
	return self.radius
end

function modifier_shadowscape:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_shadowscape:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_shadowscape:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_shadowscape:GetModifierAura()
	return "modifier_shadowscape_slow"
end

function modifier_shadowscape:IsHidden()
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_shadowscape_slow = class({})

function modifier_shadowscape_slow:OnCreated(table)
	self.slow_atack = self:GetSpecialValueFor("slow_atack")
	self.slow_move = self:GetSpecialValueFor("slow_move")
	self.slow_max = self:GetSpecialValueFor("slow_max")
	self:StartIntervalThink(0.25)

	if IsServer() then
		self.illusion_chance = self:GetSpecialValueFor("illusion_chance")
		self.illusion_damage_dealt = self:GetSpecialValueFor("illusion_damage_dealt")
		self.illusion_damage_taken = self:GetSpecialValueFor("illusion_damage_taken")
		self.illusion_duration = self:GetSpecialValueFor("illusion_duration")
	end
end

function modifier_shadowscape_slow:OnIntervalThink()
	if self.slow_move > self.slow_max then
		self.slow_atack = self.slow_atack - 2
		self.slow_move = self.slow_move - 2
	end

	if IsServer() then
		if RollPercentage(self.illusion_chance) then
			if not self:GetParent():HasModifier("modifier_dazed_generic") then
				local b = self:GetParent():GetPaddedCollisionRadius() + 50
				local randoVect = Vector(RandomInt(-b,b), RandomInt(-b,b), 0)
				local shadowling = self:GetCaster():CreateSummon(self:GetParent():GetUnitName(), self:GetParent():GetAbsOrigin()+randoVect, self.illusion_duration)
				
				shadowling:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_clone", {unit=self:GetCaster(), duration=self.illusion_duration, incomingdamage=self.illusion_damage_taken , outgoingdamage=self.illusion_damage_dealt})
				shadowling:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadowscape_clone", {})
			end

			if self:GetParent():HasModifier("modifier_penumbra") then
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_dazed_generic", {Duration=self:GetSpecialValueFor("slow_duration")})
				
				local duration = self:GetCaster():FindAbilityByName("revenant_penumbra"):GetSpecialValueFor("duration")
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_penumbra", {Duration = duration}):IncrementStackCount()
			end
		end
	end
end

function modifier_shadowscape_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_shadowscape_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.slow_move
end

function modifier_shadowscape_slow:GetModifierAttackSpeedBonus_Constant(params)
	return self.slow_atack
end

function modifier_shadowscape_slow:GetEffectName()
	return "particles/units/heroes/hero_warlock/warlock_upheaval_debuff.vpcf"
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_shadowscape_clone = class({})

function modifier_shadowscape_clone:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_shadowscape_clone:OnAttackLanded(params)
	self:GetParent():ForceKill(false)
end

function modifier_shadowscape_clone:IsHidden()
	return true
end
peacekeeper_adjudicator = class({})
LinkLuaModifier( "modifier_adjudicator", "heroes/peacekeeper/peacekeeper_adjudicator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_adjudicator_armor", "heroes/peacekeeper/peacekeeper_adjudicator.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_adjudicator:OnSpellStart()
	self.caster = self:GetCaster()

	self.buff_duration = self:GetSpecialValueFor("buff_duration")

	self.caster:AddNewModifier(self.caster,self,"modifier_adjudicator",{Duration = self.buff_duration})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_adjudicator = class({})

function modifier_adjudicator:OnCreated(table)
	self.armor_duration = self:GetSpecialValueFor("armor_duration")
	self.base_damage = self:GetSpecialValueFor("base_damage")
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.caster = self:GetCaster()

	self.bonusRange = self.caster:GetAttackRange()*2

	self.damageCumulative = 0

	if IsServer() then
		self.caster:SetProjectileModel("particles/econ/items/templar_assassin/templar_assassin_focal/templar_assassin_meld_focal_attack.vpcf")
		self:StartIntervalThink(1.0)
	end
end

function modifier_adjudicator:OnIntervalThink()
	self.damageCumulative = self.damageCumulative + self.bonus_damage
end

function modifier_adjudicator:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
	return funcs
end

function modifier_adjudicator:GetModifierAttackRangeBonus()
	return self.bonusRange
end

function modifier_adjudicator:GetEffectName()
	return "particles/units/heroes/hero_templar_assassin/templar_assassin_meld.vpcf"
end

function modifier_adjudicator:OnAttackLanded( params )
	if IsServer() then
		self.attacker = params.attacker
		self.target = params.target
		self.damageDealt = params.damage

		if self.target:GetTeam() ~= self.attacker:GetTeam() and self.attacker == self:GetCaster() then
			self.attacker:Lifesteal(self:GetAbility(), self:GetSpecialValueFor("lifesteal"), self.base_damage + self.damageCumulative, self.target, DAMAGE_TYPE_MAGICAL, DOTA_LIFESTEAL_SOURCE_ABILITY)
 			
 			self.target:AddNewModifier(self.attacker,self:GetAbility(),"modifier_adjudicator_armor",{Duration = self.armor_duration})

 			self.attacker:RevertProjectile()
 			self:Destroy()
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_adjudicator_armor = class({})

function modifier_adjudicator_armor:OnCreated(table)
	self.armor_reduc = -self:GetSpecialValueFor("armor_reduc")
end

function modifier_adjudicator_armor:IsDebuff()
	return true
end

function modifier_adjudicator_armor:GetEffectName()
	return "particles/econ/items/templar_assassin/templar_assassin_focal/templar_meld_focal_overhead.vpcf"
end

function modifier_adjudicator_armor:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_adjudicator_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_adjudicator_armor:GetModifierPhysicalArmorBonus( params )
	return self.armor_reduc
end
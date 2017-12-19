-- Custom Stat Values
CRIT_PER_STR = 5
MR_PER_STR = 0.4

ARMOR_PER_AGI = 0.07
ATKSPD_PER_AGI = 0.08

CDR_PER_INT = 0.385
SPELL_AMP_PER_INT = 0.0075

HP_PER_VIT = 20
HP_REGEN_PER_VIT = 0.05

if Stats == nil then
	Stats = class({})
end

function Stats:constructor(hero)
	self.customIntellect = hero:GetBaseIntellect()
	self.customStrength = hero:GetBaseStrength()
	self.customAgility = hero:GetBaseAgility()
	self.customVitality = hero:GetBaseVitality()
	self.customLuck = hero:GetBaseLuck()
	
	self.customIntellectGain = hero:GetIntellectGain()
	self.customStrengthGain = hero:GetStrengthGain()
	self.customAgilityGain = hero:GetAgilityGain()
	self.customVitalityGain = hero:GetVitalityGain()
	self.customLuckGain = hero:GetLuckGain()
end

function Stats:ManageStats(hero)
	local ogHero = hero
	if hero:IsIllusion() then ogHero = hero:GetOwnerEntity() end
	local data = CustomNetTables:GetTableValue("hero_properties", hero:GetUnitName()..ogHero:entindex() ) or {}
	self.customIntellect = hero:GetBaseIntellect() + hero:GetLevel() * hero:GetIntellectGain()
	self.customStrength = hero:GetBaseStrength() + hero:GetLevel() * hero:GetStrengthGain()
	self.customAgility = hero:GetBaseAgility() + hero:GetLevel() * hero:GetAgilityGain()
	self.customVitality = hero:GetBaseVitality() + hero:GetLevel() * hero:GetVitalityGain()
	self.customLuck = hero:GetBaseLuck() + hero:GetLevel() * hero:GetLuckGain()
	
	data.evasion = 0
	data.spellamp = 0
	data.cdr = 0
	data.castrange = 0
	data.statusamp = 0
	data.statusresistance = 0
	data.damageamp = 0
	data.damageresistance = 0
	data.healamp = 0
	data.dot = 0
	data.hot = 0
	for _, modifier in ipairs(hero:FindAllModifiers()) do
		-- Attribute management
		if modifier.GetModifierBonusStats_Strength and modifier:GetModifierBonusStats_Strength() then
			self.customStrength = self.customStrength + modifier:GetModifierBonusStats_Strength()
		end
		if modifier.GetModifierBonusStats_Intellect and modifier:GetModifierBonusStats_Intellect() then
			self.customIntellect = self.customIntellect + modifier:GetModifierBonusStats_Intellect()
		end
		if modifier.GetModifierBonusStats_Agility and modifier:GetModifierBonusStats_Agility() then
			self.customAgility = self.customAgility + modifier:GetModifierBonusStats_Agility()
		end
		if modifier.GetModifierBonusStats_Luck and modifier:GetModifierBonusStats_Luck() then
			self.customLuck = self.customLuck + modifier:GetModifierBonusStats_Luck()
		end
		if modifier.GetModifierBonusStats_Vitality and modifier:GetModifierBonusStats_Vitality() then
			self.customVitality = self.customVitality + modifier:GetModifierBonusStats_Vitality()
		end
		
		-- Modifier property management
		local event = {}
		event.damage = 0
		event.damage_flags = 0
		event.attacker = hero
		event.target = hero
		event.unit = hero
		event.original_damage = 0
		event.ability = 0
		if modifier.GetModifierEvasion_Constant and modifier:GetModifierEvasion_Constant(event) then
			local evasion = data.evasion or 0
			local hitChance = 1 - evasion/100
			data.evasion = evasion + hitChance * modifier:GetModifierEvasion_Constant(event)/100
		end
		if modifier.GetModifierSpellAmplify_Percentage and modifier:GetModifierSpellAmplify_Percentage(event) then
			data.spellamp = data.spellamp + modifier:GetModifierSpellAmplify_Percentage(event)
		end
		if modifier.GetModifierCastRangeBonusStacking and modifier:GetModifierCastRangeBonusStacking(event) then
			data.castrange = data.castrange + modifier:GetModifierCastRangeBonusStacking(event)
		end
		if modifier.GetModifierStatusAmplification and modifier:GetModifierStatusAmplification(event) then
			data.statusamp = data.statusamp + modifier:GetModifierStatusAmplification(event)
		end
		if modifier.GetModifierStatusResistance and modifier:GetModifierStatusResistance(event) then
			data.statusresistance = data.statusresistance + modifier:GetModifierStatusResistance(event)
		end
		if modifier.GetModifierPercentageCooldownStacking and modifier:GetModifierPercentageCooldownStacking(event) then
			data.cdr = data.cdr + modifier:GetModifierPercentageCooldownStacking(event) / 100
		end
		local cdr = 0
		if modifier.GetModifierPercentageCooldown and modifier:GetModifierPercentageCooldown(event) then
			cdr = math.max(cdr, modifier:GetModifierPercentageCooldown(event))
		end
		data.cdr = 1 - ((1 - data.cdr) * (1 - (cdr / 100)))
		if modifier.GetModifierTotalDamageOutgoing_Percentage and modifier:GetModifierTotalDamageOutgoing_Percentage(event) then
			data.damageamp = data.damageamp + modifier:GetModifierTotalDamageOutgoing_Percentage(event)
		end
		if modifier.GetModifierIncomingDamage_Percentage and modifier:GetModifierIncomingDamage_Percentage(event) then
			data.damageresistance = data.damageresistance + modifier:GetModifierIncomingDamage_Percentage(event)
		end
		if modifier.GetModifierHealAmplify_Percentage and modifier:GetModifierHealAmplify_Percentage(event) then
			data.healamp = data.healamp + modifier:GetModifierHealAmplify_Percentage(event)
		end
		if modifier.GetTotalHeal and modifier:GetTotalHeal(event) then
			data.hot = data.hot + modifier:GetTotalHeal(event)
		end
		if modifier.GetTotalDamage and modifier:GetTotalDamage(event) then
			data.dot = data.dot + modifier:GetTotalDamage(event)
		end
	end
	
	self.customIntellect = math.floor(self.customIntellect + 0.5)
	self.customStrength = math.floor(self.customStrength + 0.5)
	self.customAgility = math.floor(self.customAgility + 0.5)
	self.customVitality = math.floor(self.customVitality + 0.5)
	self.customLuck = math.floor(self.customLuck + 0.5)
	
	-- attributes
	data.intellect = self.customIntellect
	data.strength = self.customStrength
	data.agility = self.customAgility
	data.vitality = self.customVitality
	data.luck = self.customLuck
	
	
	hero:AddNewModifier(hero, nil, "modifier_stat_handler", {})
	CustomNetTables:SetTableValue("hero_properties", hero:GetUnitName()..ogHero:entindex(), data )
	
	hero:CalculateStatBonus()
end

modifier_stat_handler = class({})
LinkLuaModifier("modifier_stat_handler", "stats.lua", 0)

function modifier_stat_handler:OnCreated()
    self.ARMOR_PER_STR = 0.07
	self.MR_PER_STR = 0.1
	
	self.ATKSPD_PER_AGI = 1
	self.MS_PER_AGI = 0.072
	
	self.MANA_PER_INT = 12
	self.MANA_REGEN_PER_INT = 0.08
	self.SPELL_AMP_PER_INT = 0.05
	
	self.HP_PER_VIT = 20
	self.HP_REGEN_PER_VIT = 0.2
	
	self.EVASION_PER_LUCK = 0.08
	
	self.intelligence = self:GetParent():GetIntellect()
	self.strength = self:GetParent():GetStrength()
	self.agility = self:GetParent():GetAgility()
	self.vitality = self:GetParent():GetVitality()
	self.luck = self:GetParent():GetLuck()
end

function modifier_stat_handler:OnRefresh()
    self.intelligence = self:GetParent():GetIntellect()
	self.strength = self:GetParent():GetStrength()
	self.agility = self:GetParent():GetAgility()
	self.vitality = self:GetParent():GetVitality()
	self.luck = self:GetParent():GetLuck()
end

function modifier_stat_handler:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT
    }

    return funcs
end

function modifier_stat_handler:GetModifierEvasion_Constant()
	return self.luck * self.EVASION_PER_LUCK
end

function modifier_stat_handler:GetModifierBaseAttack_BonusDamage()
	local parent = self:GetParent()
	if parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
		return parent:GetStrength()
	elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
		return parent:GetAgility()
	elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
		return parent:GetIntellect()
	end
end

function modifier_stat_handler:GetModifierHealthBonus( )
    return self.vitality * self.HP_PER_VIT
end

function modifier_stat_handler:GetModifierConstantHealthRegen( )
    return self.vitality * self.HP_REGEN_PER_VIT
end

function modifier_stat_handler:GetModifierMagicalResistanceBonus( params )
    return self.strength * self.MR_PER_STR
end

function modifier_stat_handler:GetModifierPhysicalArmorBonus( params )
    return self.strength * self.ARMOR_PER_STR
end

function modifier_stat_handler:GetModifierAttackSpeedBonus_Constant( params )
    return self.agility * self.ATKSPD_PER_AGI
end

function modifier_stat_handler:GetModifierMoveSpeedBonus_Constant( params )
    return self.agility * self.MS_PER_AGI
end

function modifier_stat_handler:GetModifierConstantManaRegen( params )
    return self.intelligence * self.MANA_REGEN_PER_INT
end

function modifier_stat_handler:GetModifierManaBonus( params )
    return self.intelligence * self.MANA_PER_INT
end

function modifier_stat_handler:GetModifierSpellAmplify_Percentage( params )
    return self.intelligence * self.SPELL_AMP_PER_INT
end

function modifier_stat_handler:IsHidden()
    return true
end

function modifier_stat_handler:AllowIllusionDuplicate()
    return true
end

function modifier_stat_handler:RemoveOnDeath()
    return false
end

function modifier_stat_handler:IsPurgable()
    return false
end
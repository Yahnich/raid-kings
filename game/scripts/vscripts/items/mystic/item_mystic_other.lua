item_mystic_other_1 = class({})

function item_mystic_other_1:GetIntrinsicModifierName()
	return "modifier_item_mystic_other"
end

item_mystic_other_2 = class(item_mystic_other_1)
item_mystic_other_3 = class(item_mystic_other_1)
item_mystic_other_4 = class(item_mystic_other_1)
item_mystic_other_5 = class(item_mystic_other_1)

modifier_item_mystic_other = class({})
LinkLuaModifier("modifier_item_mystic_other", "items/mystic/item_mystic_other.lua", 0)

function modifier_item_mystic_other:OnCreated()
	self.amp = self:GetSpecialValueFor("evasion")
	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetSpecialValueFor("crit_damage")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_mystic_other:OnRefresh()
	self.amp = self:GetSpecialValueFor("evasion")
	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetSpecialValueFor("crit_damage")
end

function modifier_item_mystic_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_item_mystic_other:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_item_mystic_other:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.inflictor and RollPercentage(self.crit_chance) then
		params.target:ShowPopup( {
						PostSymbol = 4,
						Color = Vector( 125, 125, 255 ),
						Duration = 0.5,
						Number = params.damage * self.crit_dmg,
						pfx = "spell"} )
		return 100 - self.crit_dmg
	end
end

function modifier_item_mystic_other:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(self.crit_chance) then
		return self.crit_dmg
	end
end

function modifier_item_mystic_other:IsHidden()
	return true
end
item_mystic_armor_1 = class({})

function item_mystic_armor_1:GetIntrinsicModifierName()
	return "modifier_item_mystic_armor"
end

item_mystic_armor_2 = class(item_mystic_armor_1)
item_mystic_armor_3 = class(item_mystic_armor_1)
item_mystic_armor_4 = class(item_mystic_armor_1)
item_mystic_armor_5 = class(item_mystic_armor_1)

modifier_item_mystic_armor = class({})
LinkLuaModifier("modifier_item_mystic_armor", "items/mystic/item_mystic_armor.lua", 0)

function modifier_item_mystic_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.armor = self:GetSpecialValueFor("magic_resist")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_mystic_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.armor = self:GetSpecialValueFor("magic_resist")
end

function modifier_item_mystic_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_item_mystic_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_mystic_armor:GetModifierMagicalResistanceBonus()
	return self.armor
end

function modifier_item_mystic_armor:IsHidden()
	return true
end
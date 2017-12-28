item_avalanche_armor_1 = class({})

function item_avalanche_armor_1:GetIntrinsicModifierName()
	return "modifier_item_avalanche_armor"
end

item_avalanche_armor_2 = class(item_avalanche_armor_1)
item_avalanche_armor_3 = class(item_avalanche_armor_1)
item_avalanche_armor_4 = class(item_avalanche_armor_1)
item_avalanche_armor_5 = class(item_avalanche_armor_1)

modifier_item_avalanche_armor = class({})
LinkLuaModifier("modifier_item_avalanche_armor", "items/avalanche/item_avalanche_armor.lua", 0)

function modifier_item_avalanche_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_avalanche_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
end

function modifier_item_avalanche_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_item_avalanche_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_avalanche_armor:IsHidden()
	return true
end
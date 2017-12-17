item_revenant_armor_1 = class({})

function item_revenant_armor_1:GetIntrinsicModifierName()
	return "modifier_item_revenant_armor"
end

item_revenant_armor_2 = class(item_revenant_armor_1)
item_revenant_armor_3 = class(item_revenant_armor_1)
item_revenant_armor_4 = class(item_revenant_armor_1)
item_revenant_armor_5 = class(item_revenant_armor_1)

modifier_item_revenant_armor = class({})
LinkLuaModifier("modifier_item_revenant_armor", "items/revenant/item_revenant_armor.lua", 0)

function modifier_item_revenant_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_revenant_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
end

function modifier_item_revenant_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_item_revenant_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_revenant_armor:IsHidden()
	return true
end
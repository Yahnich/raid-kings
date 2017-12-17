item_peacekeeper_other_1 = class({})

function item_peacekeeper_other_1:GetIntrinsicModifierName()
	return "modifier_item_peacekeeper_other"
end

item_peacekeeper_other_2 = class(item_peacekeeper_other_1)
item_peacekeeper_other_3 = class(item_peacekeeper_other_1)
item_peacekeeper_other_4 = class(item_peacekeeper_other_1)
item_peacekeeper_other_5 = class(item_peacekeeper_other_1)

modifier_item_peacekeeper_other = class({})
LinkLuaModifier("modifier_item_peacekeeper_other", "items/peacekeeper/item_peacekeeper_other.lua", 0)

function modifier_item_peacekeeper_other:OnCreated()
	self.bonus_as = self:GetSpecialValueFor("bonus_atkspeed")
	self.cdr = self:GetSpecialValueFor("cdr")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_peacekeeper_other:OnRefresh()
	self.bonus_as = self:GetSpecialValueFor("bonus_atkspeed")
	self.cdr = self:GetSpecialValueFor("cdr")
end

function modifier_item_peacekeeper_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_peacekeeper_other:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_item_peacekeeper_other:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_item_peacekeeper_other:IsHidden()
	return true
end
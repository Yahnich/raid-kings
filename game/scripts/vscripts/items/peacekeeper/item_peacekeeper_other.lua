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
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_peacekeeper_other:OnRefresh()
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_peacekeeper_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_peacekeeper_other:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_item_peacekeeper_other:IsHidden()
	return true
end
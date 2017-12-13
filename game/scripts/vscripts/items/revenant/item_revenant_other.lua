item_revenant_other_1 = class({})

function item_revenant_other_1:GetIntrinsicModifierName()
	return "modifier_item_revenant_other"
end

item_revenant_other_2 = class(item_revenant_other_1)
item_revenant_other_3 = class(item_revenant_other_1)
item_revenant_other_4 = class(item_revenant_other_1)
item_revenant_other_5 = class(item_revenant_other_1)

modifier_item_revenant_other = class({})
LinkLuaModifier("modifier_item_revenant_other", "items/revenant/item_revenant_other.lua", 0)

function modifier_item_revenant_other:OnCreated()
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_revenant_other:OnRefresh()
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_revenant_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_revenant_other:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_item_revenant_other:IsHidden()
	return true
end
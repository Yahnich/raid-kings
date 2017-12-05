item_guardian_armor_1 = class({})

function item_guardian_armor_1:GetIntrinsicModifierName()
	return "modifier_item_guardian_armor"
end

item_guardian_armor_2 = class(item_guardian_armor_1)
item_guardian_armor_3 = class(item_guardian_armor_1)
item_guardian_armor_4 = class(item_guardian_armor_1)
item_guardian_armor_5 = class(item_guardian_armor_1)

modifier_item_guardian_armor = class({})
LinkLuaModifier("modifier_item_guardian_armor", "items/guardian/item_guardian_armor.lua", 0)

function modifier_item_guardian_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.bonus_hp = self:GetSpecialValueFor("armor")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_guardian_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.bonus_hp = self:GetSpecialValueFor("armor")
end

function modifier_item_guardian_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_guardian_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_guardian_armor:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_guardian_armor:IsHidden()
	return true
end
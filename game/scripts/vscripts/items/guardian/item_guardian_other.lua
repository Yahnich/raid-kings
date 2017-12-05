item_guardian_other_1 = class({})

function item_guardian_other_1:GetIntrinsicModifierName()
	return "modifier_item_guardian_other"
end

item_guardian_other_2 = class(item_guardian_other_1)
item_guardian_other_3 = class(item_guardian_other_1)
item_guardian_other_4 = class(item_guardian_other_1)
item_guardian_other_5 = class(item_guardian_other_1)

modifier_item_guardian_other = class({})
LinkLuaModifier("modifier_item_guardian_other", "items/guardian/item_guardian_other.lua", 0)

function modifier_item_guardian_other:OnCreated()
	self.evasion = self:GetSpecialValueFor("evasion")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_guardian_other:OnRefresh()
	self.evasion = self:GetSpecialValueFor("evasion")
end

function modifier_item_guardian_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_item_guardian_other:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_guardian_other:IsHidden()
	return true
end
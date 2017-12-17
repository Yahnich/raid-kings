item_mystic_weapon_1 = class({})

function item_mystic_weapon_1:GetIntrinsicModifierName()
	return "modifier_item_mystic_weapon"
end

item_mystic_weapon_2 = class(item_mystic_weapon_1)
item_mystic_weapon_3 = class(item_mystic_weapon_1)
item_mystic_weapon_4 = class(item_mystic_weapon_1)
item_mystic_weapon_5 = class(item_mystic_weapon_1)

modifier_item_mystic_weapon = class({})
LinkLuaModifier("modifier_item_mystic_weapon", "items/mystic/item_mystic_weapon.lua", 0)

function modifier_item_mystic_weapon:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.cdr = self:GetSpecialValueFor("cdr")
end

function modifier_item_mystic_weapon:OnRefresh()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.cdr = self:GetSpecialValueFor("cdr")
end

function modifier_item_mystic_weapon:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function modifier_item_mystic_weapon:GetModifierBaseAttack_BonusDamage()
	return self.bonus_dmg
end


function modifier_item_mystic_weapon:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_item_mystic_weapon:IsHidden()
	return true
end
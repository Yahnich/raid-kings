item_buccaneer_weapon_1 = class({})

function item_buccaneer_weapon_1:GetIntrinsicModifierName()
	return "modifier_item_buccaneer_weapon"
end

item_buccaneer_weapon_2 = class(item_buccaneer_weapon_1)
item_buccaneer_weapon_3 = class(item_buccaneer_weapon_1)
item_buccaneer_weapon_4 = class(item_buccaneer_weapon_1)
item_buccaneer_weapon_5 = class(item_buccaneer_weapon_1)

modifier_item_buccaneer_weapon = class({})
LinkLuaModifier("modifier_item_buccaneer_weapon", "items/buccaneer/item_buccaneer_weapon.lua", 0)

function modifier_item_buccaneer_weapon:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_buccaneer_weapon:OnRefresh()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_buccaneer_weapon:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_item_buccaneer_weapon:GetModifierBaseAttack_BonusDamage()
	return self.bonus_dmg
end

function modifier_item_buccaneer_weapon:IsHidden()
	return true
end
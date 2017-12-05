item_guardian_weapon_1 = class({})

function item_guardian_weapon_1:GetIntrinsicModifierName()
	return "modifier_item_guardian_weapon"
end

item_guardian_weapon_2 = class(item_guardian_weapon_1)
item_guardian_weapon_3 = class(item_guardian_weapon_1)
item_guardian_weapon_4 = class(item_guardian_weapon_1)
item_guardian_weapon_5 = class(item_guardian_weapon_1)

modifier_item_guardian_weapon = class({})
LinkLuaModifier("modifier_item_guardian_weapon", "items/guardian/item_guardian_weapon.lua", 0)

function modifier_item_guardian_weapon:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.atk_spd = self:GetSpecialValueFor("bonus_atkspeed")
end

function modifier_item_guardian_weapon:OnRefresh()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.atk_spd = self:GetSpecialValueFor("bonus_atkspeed")
end

function modifier_item_guardian_weapon:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_guardian_weapon:GetModifierBaseAttack_BonusDamage()
	return self.bonus_dmg
end


function modifier_item_guardian_weapon:GetModifierAttackSpeedBonus_Constant()
	return self.atk_spd
end

function modifier_item_guardian_weapon:IsHidden()
	return true
end
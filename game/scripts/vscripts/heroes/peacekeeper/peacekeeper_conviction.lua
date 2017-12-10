peacekeeper_conviction = class({})
LinkLuaModifier( "modifier_conviction", "heroes/peacekeeper/peacekeeper_conviction.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_conviction:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")
	local units = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		unit:AddNewModifier(caster,self,"modifier_conviction",{Duration = duration})
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_conviction = class({})

function modifier_conviction:OnCreated(table)
	self.caster = self:GetCaster()

	self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
end
function modifier_conviction:GetEffectName()
	return "particles/heroes/peacekeeper/peacekeeper_conviction.vpcf"
end

function modifier_conviction:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_conviction:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

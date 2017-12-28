avalanche_arctic_avatar = class({})
LinkLuaModifier( "modifier_arctic_avatar", "heroes/avalanche/avalanche_arctic_avatar.lua" ,LUA_MODIFIER_MOTION_NONE )

function avalanche_arctic_avatar:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_arctic_avatar", {Duration = duration})

	local units = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		if unit:HasModifier("modifier_chill_generic") then
			unit:RemoveModifierByName("modifier_chill_generic")
			unit:Freeze(self, caster, 1)
		end
	end
end

modifier_arctic_avatar = class({})

function modifier_arctic_avatar:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_arctic_avatar:OnAttackLanded(params)
	if params.target:GetTeam() ~= self:GetCaster():GetTeam() then
		params.target:AddChill(self:GetAbility(), self:GetCaster(), self:GetSpecialValueFor("chill_duration"))
	end
end

function modifier_arctic_avatar:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_armor.vpcf"
end

function modifier_arctic_avatar:StatusEffectPriority()
	return 10
end

function modifier_arctic_avatar:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
end
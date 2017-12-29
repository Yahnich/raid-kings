avalanche_frostbrand = class({})
LinkLuaModifier( "modifier_frostbrand", "heroes/avalanche/avalanche_frostbrand.lua" ,LUA_MODIFIER_MOTION_NONE )

function avalanche_frostbrand:GetIntrinsicModifierName()
	return "modifier_frostbrand"
end

modifier_frostbrand = class({})

function modifier_frostbrand:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_frostbrand:GetModifierDamageOutgoing_Percentage(params)
	if params.target and params.target:GetTeam() ~= self:GetCaster():GetTeam() then
		if params.target:HasModifier("modifier_chill_generic") then
			return params.target:GetChillCount()*self:GetAbility():GetSpecialValueFor("bonus_damage")
		else
			return 100
		end
	end
end

function modifier_frostbrand:IsHidden()
	return true
end
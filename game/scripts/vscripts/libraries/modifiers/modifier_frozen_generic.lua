modifier_frozen_generic = class({})
function modifier_frozen_generic:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_FROZEN] = true}
	return state
end

function modifier_frozen_generic:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_frozen_generic:IsPurgable()
	return true
end

function modifier_frozen_generic:IsDebuff()
	return true
end

function modifier_frozen_generic:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_frozen_generic:HeroEffectPriority()
	return 10
end

function modifier_frozen_generic:GetTexture()
	return "crystal_maiden_frostbite"
end
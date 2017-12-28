modifier_chill_generic = class({})
function modifier_chill_generic:OnCreated(table)
	if IsServer() then
		if self:GetStackCount() > 99 then
			self:GetParent():Freeze(self:GetAbility(), self:GetCaster(), 1)
			self:Destroy()
		end
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_chill_generic:OnRefresh(table)
	if IsServer() then
		if self:GetStackCount() > 99 then
			self:GetParent():Freeze(self:GetAbility(), self:GetCaster(), 1)
			self:Destroy()
		end
	end
end

function modifier_chill_generic:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() > 99 then
			self:GetParent():Freeze(self:GetAbility(), self:GetCaster(), 1)
			self:Destroy()
		end
	end
end

function modifier_chill_generic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_chill_generic:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self:GetStackCount()
end

function modifier_chill_generic:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_chill_generic:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_armor.vpcf"
end

function modifier_chill_generic:StatusEffectPriority()
	return 10
end

function modifier_chill_generic:IsPurgable()
	return true
end

function modifier_chill_generic:IsDebuff()
	return true
end

function modifier_chill_generic:GetTexture()
	return "crystal_maiden_crystal_nova"
end
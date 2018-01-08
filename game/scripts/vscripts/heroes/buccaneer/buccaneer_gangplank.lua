buccaneer_gangplank = class({})
LinkLuaModifier( "modifier_gangplank", "heroes/buccaneer/buccaneer_gangplank.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_gangplank:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Kunkka.TauntJig", target)

	if target:HasModifier("modifier_buccaneer_jolly_roger") then
		local gold = caster:FindAbilityByName("buccaneer_jolly_roger"):GetSpecialValueFor( "gold" ) * self:GetSpecialValueFor( "gold_multiplier" )
		caster:ModifyGold(gold,true,0)
		SendOverheadEventMessage(caster:GetPlayerOwner(),OVERHEAD_ALERT_GOLD,caster,gold,caster)
		target:AddNewModifier(caster, self, "modifier_gangplank", {Duration=self:GetSpecialValueFor( "duration" )})
	else
		target:AddNewModifier(caster, self, "modifier_gangplank", {Duration=self:GetSpecialValueFor( "duration" )})
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_gangplank = class({})

function modifier_gangplank:OnCreated( kv )
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_gangplank:OnIntervalThink()
	self:GetParent():MoveToNPC(self:GetCaster())
end

function modifier_gangplank:OnRemoved()
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/econ/courier/courier_kunkka_parrot/courier_kunkka_parrot_splash.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nfx)

		StopSoundOn("Hero_Kunkka.TauntJig", self:GetParent())
		self:GetParent():Stop()
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor( "damage" ), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned_generic", {Duration=self:GetSpecialValueFor( "stun_duration" )})
	end
end

function modifier_gangplank:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_gangplank:GetModifierMoveSpeedBonus_Percentage()
	return -100
end

function modifier_gangplank:GetStatusEffectName()
	return "particles/status_fx/status_effect_rum.vpcf"
end

function modifier_gangplank:StatusEffectPriority()
	return 10
end

function modifier_gangplank:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end

function modifier_gangplank:IsDebuff()
	return true
end

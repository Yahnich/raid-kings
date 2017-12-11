revenant_umbral_gate = class({})
LinkLuaModifier( "modifier_umbral_gate", "heroes/revenant/revenant_umbral_gate.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_umbral_gate_enemy", "heroes/revenant/revenant_umbral_gate.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_umbral_gate_slow", "heroes/revenant/revenant_umbral_gate.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_umbral_gate:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()


	local gate_duration = self:GetSpecialValueFor("gate_duration")

	local modifier = CreateModifierThinker(caster, self, "modifier_umbral_gate", {Duration = gate_duration}, point, caster:GetTeam(), false)
	EmitSoundOn("Hero_ShadowDemon.Disruption", modifier)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Modifier Thinker
modifier_umbral_gate = class({})

function modifier_umbral_gate:OnCreated(table)
	self.illusion_damage_dealt = self:GetSpecialValueFor("illusion_damage_dealt")
	self.illusion_damage_taken = self:GetSpecialValueFor("illusion_damage_taken")
	self.illusion_duration = self:GetSpecialValueFor("illusion_duration")

	if IsServer() then
		self:StartIntervalThink(1.5)
	end
end

function modifier_umbral_gate:OnIntervalThink()
	if IsServer() then
		local b = 250
		local randoVect = Vector(RandomInt(-b,b), RandomInt(-b,b), 0)
		local shadowling = self:GetCaster():CreateSummon(self:GetCaster():GetUnitName(), self:GetParent():GetAbsOrigin()+randoVect, self.illusion_duration)
		
		shadowling:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_clone", {unit=self:GetCaster(), duration=self.illusion_duration, incomingdamage=self.illusion_damage_taken, outgoingdamage=self.illusion_damage_dealt})
		shadowling:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_umbral_gate_enemy", {})
	end
end

function modifier_umbral_gate:GetEffectName()
	return "particles/units/heroes/hero_shadow_demon/shadow_demon_disruption.vpcf"
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_umbral_gate_enemy = class({})

function modifier_umbral_gate_enemy:OnCreated(table)
	self.slow_duration = self:GetSpecialValueFor("slow_duration")

	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_umbral_gate_enemy:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():GetAttackTarget() ~= nil then
			self:GetParent():SetForceAttackTarget(self:GetCaster():GetAttackTarget())
		end
	end
end

function modifier_umbral_gate_enemy:IsHidden()
	return true
end

function modifier_umbral_gate_enemy:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_umbral_gate_enemy:OnAttackLanded( params )
	if params.attacker == self:GetParent() then
		if params.target:HasModifier("modifier_penumbra") then
			params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_umbral_gate_slow", {Duration=self.slow_duration})
		end
	end
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_umbral_gate_slow = class({})

function modifier_umbral_gate_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_umbral_gate_slow:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetSpecialValueFor("slow")
end

function modifier_umbral_gate_slow:IsHidden()
    return false
end

function modifier_umbral_gate_slow:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_umbral_gate_slow:IsDebuff()
    return true
end
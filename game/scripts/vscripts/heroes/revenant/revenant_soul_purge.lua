revenant_soul_purge = class({})
LinkLuaModifier( "modifier_soul_purge", "heroes/revenant/revenant_soul_purge.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_penumbra", "heroes/revenant/revenant_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_soul_purge:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function revenant_soul_purge:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	local max_targets = self:GetSpecialValueFor("max_targets")

	EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Cast", caster)

	local units = caster:FindEnemyUnitsInRadius(point, radius, {})
	local currentunits = 0
	for _,unit in pairs(units) do
		if currentunits < max_targets then
			unit:Purge(true, false, false, false, false)
			unit:AddNewModifier(caster, self, "modifier_soul_purge", {Duration = duration})
			EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Impact", unit)
		else
			break
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_soul_purge = class({})

function modifier_soul_purge:OnCreated(table)
	self.slow = self:GetSpecialValueFor("slow")
	self:StartIntervalThink(self:GetDuration()/5)
end

function modifier_soul_purge:OnIntervalThink()
	self.slow = self.slow - self.slow/5
end

function modifier_soul_purge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_soul_purge:GetEffectName()
	return "particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge.vpcf"
end

function modifier_soul_purge:GetModifierMoveSpeedBonus_Percentage(params)
	return self.slow
end

function modifier_soul_purge:OnRemoved()
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		if self:GetParent():HasModifier("modifier_penumbra") then
			local duration = self:GetCaster():FindAbilityByName("ms_shadow_shade"):GetSpecialValueFor("duration")
					
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_penumbra", {Duration = duration}):IncrementStackCount()
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_penumbra", {Duration = duration}):IncrementStackCount()
			self:GetParent():RemoveModifierByName("modifier_penumbra")
		end
	end
end

function modifier_soul_purge:IsDebuff()
	return true
end
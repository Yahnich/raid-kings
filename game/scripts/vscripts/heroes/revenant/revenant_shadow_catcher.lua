revenant_shadow_catcher = class({})
LinkLuaModifier( "modifier_shadow_catcher", "heroes/revenant/revenant_shadow_catcher.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_clone", "libraries/modifiers/modifier_shadow_clone.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_penumbra", "heroes/revenant/revenant_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_shadow_catcher:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function revenant_shadow_catcher:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")

	EmitSoundOn("Hero_ShadowDemon.Soul_Catcher.Cast", caster)

	local units = caster:FindEnemyUnitsInRadius(point, radius, {})
	for _,unit in pairs(units) do
		unit:AddNewModifier(caster, self, "modifier_shadow_catcher", {Duration = duration})
		EmitSoundOn("Hero_ShadowDemon.Soul_Catcher", unit)
		break
	end

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, point )
	ParticleManager:SetParticleControl(nfx, 1, point )
	ParticleManager:SetParticleControl(nfx, 2, point )
	ParticleManager:SetParticleControl(nfx, 3, Vector(radius,radius,radius))
	ParticleManager:SetParticleControl(nfx, 4, point )
	ParticleManager:SetParticleControl(nfx, 6, point )
	ParticleManager:ReleaseParticleIndex(nfx)

	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(nfx, true)
	end)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_shadow_catcher = class({})

function modifier_shadow_catcher:OnCreated(table)
	self.damage_amp = self:GetSpecialValueFor("damage_amp")
	self.illusion_damage_dealt = self:GetSpecialValueFor("illusion_damage_dealt")
	self.illusion_damage_taken = self:GetSpecialValueFor("illusion_damage_taken")
	self.illusion_duration = self:GetSpecialValueFor("illusion_duration")
end

function modifier_shadow_catcher:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_shadow_catcher:OnDeath(params)
	if params.unit == self:GetParent() then
		
		local shadowling = self:GetCaster():CreateSummon(self:GetParent():GetUnitName(), self:GetParent():GetAbsOrigin(), self.illusion_duration)
		shadowling:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_clone", {duration=self.illusion_duration, incomingdamage=self.illusion_damage_taken , outgoingdamage=self.illusion_damage_dealt})
		
		if params.unit:HasModifier("modifier_penumbra") then
			
			local nfx = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_POINT, self:GetCaster())
			ParticleManager:SetParticleControl(nfx, 0, params.unit:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex(nfx)
			Timers:CreateTimer(1.0, function()
				ParticleManager:DestroyParticle(nfx, true)
			end)

			local units = self:GetCaster():FindEnemyUnitsInRadius(params.unit:GetAbsOrigin(), 500, {})
			for _,unit in pairs(units) do
				local duration = self:GetCaster():FindAbilityByName("revenant_penumbra"):GetSpecialValueFor("duration")
				
				unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_penumbra", {Duration = duration}):IncrementStackCount()
			end
		end
	end
end

function modifier_shadow_catcher:GetModifierIncomingDamage_Percentage(params)
	return self.damage_amp
end

function modifier_shadow_catcher:GetEffectName()
	return "particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher_debuff.vpcf"
end

function modifier_shadow_catcher:IsDebuff()
	return true
end
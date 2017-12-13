revenant_dark_flay = class({})
LinkLuaModifier( "modifier_dark_flay", "heroes/revenant/revenant_dark_flay.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_penumbra", "heroes/revenant/revenant_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_dark_flay:GetChannelTime()
	return self:GetSpecialValueFor("max_channel")
end

function revenant_dark_flay:GetChannelAnimation()
	return "ACT_DOTA_GENERIC_CHANNEL_1"
end

function revenant_dark_flay:GetChannelledManaCostPerSecond(iLevel)
	return self:GetManaCost(iLevel)
end

function revenant_dark_flay:OnSpellStart()
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	self.radius = self:GetSpecialValueFor("radius")
	self.newRadius = 0

	EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Cast", caster)

	self.nfx = ParticleManager:CreateParticle( "particles/heroes/revenant/revenant_dark_flay.vpcf", PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( self.nfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	

	self.target:AddNewModifier(caster, self, "modifier_dark_flay", {})
	self.target:AddNewModifier(caster, self, "modifier_dazed_generic", {})
end

function revenant_dark_flay:OnChannelFinish(bInterrupted)
	ParticleManager:DestroyParticle(self.nfx, false)	
	self.target:RemoveModifierByName("modifier_dark_flay")
	self.target:RemoveModifierByName("modifier_dazed_generic")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_dark_flay = class({})

function modifier_dark_flay:OnCreated(table)
	if IsServer() then
		self.damage_second = self:GetSpecialValueFor("damage_second")/2
		self.radius = self:GetSpecialValueFor("radius")
		self:StartIntervalThink(0.5)
	end
end

function modifier_dark_flay:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsMagicImmune() then
			local damageTaken = self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage_second, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			if self:GetParent():HasModifier("modifier_penumbra") then
				local units = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius, {})
				for _,unit in pairs(units) do
					if unit ~= self:GetParent() then
						self.nfx2 = ParticleManager:CreateParticle( "particles/heroes/revenant/revenant_dark_flay_reflect.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
						ParticleManager:SetParticleControlEnt( self.nfx2, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true )
						ParticleManager:SetParticleControlEnt( self.nfx2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
						ParticleManager:ReleaseParticleIndex(self.nfx2)
						self:GetAbility():DealDamage(self:GetCaster(), unit, damageTaken, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
						break
					end
				end
			end
		end
	end
end

function modifier_dark_flay:GetTotalDamage()
	return self.damage_second*self:GetRemainingTime()
end
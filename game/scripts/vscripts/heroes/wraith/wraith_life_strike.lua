wraith_life_strike = class({})

function wraith_life_strike:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Magnataur.ShockWave.Cast", self:GetCaster())
	self.warmUp = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_wraithfire_warmup.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.warmUp, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	return true
end

function wraith_life_strike:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Magnataur.ShockWave.Cast", self:GetCaster())
	ParticleManager:DestroyParticle(self.warmUp ,false)
	ParticleManager:ReleaseParticleIndex(self.warmUp)
end

function wraith_life_strike:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()

	local projectileFX = "particles/heroes/wraith/wraith_life_strikewave.vpcf"
	
	local vDir = CalculateDirection(position, caster)
	local speed = self:GetSpecialValueFor("wave_speed")
	local velocity = vDir * speed
	local distance = self:GetSpecialValueFor("wave_distance")
	local width = self:GetSpecialValueFor("wave_width")

	damage = self:GetSpecialValueFor("wave_damage")

	healPerc = self:GetTalentSpecialValueFor("life_leeched") / 100

	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()

		local heal = damage * healPerc
		if not target then return end
		if target ~= nil and target:GetTeam() ~= caster:GetTeam() then
			if not self.hitUnits[target:entindex()] then
				self:GetAbility():DealDamage(caster, target, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				if caster:GetHealth() + heal > caster:GetMaxHealth() then
					local difference = caster:GetMaxHealth() - caster:GetHealth()
					caster:HealEvent(difference, self:GetAbility(), caster)
					local particle1 = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_lifestrike_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(particle1, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
						ParticleManager:SetParticleControlEnt(particle1, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(particle1)
					local spreadheal = heal - difference
					--print(difference, spreadheal, "first spread")	
					local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), 900, {})
					for _, ally in pairs(allies) do
						if spreadheal > 0 and ally ~= caster then
							--print("spreading", ally:GetHealth(), ally:GetMaxHealth())
							if ally:GetHealth() < ally:GetMaxHealth() then
								if ally:GetHealth() + spreadheal > ally:GetMaxHealth() then
									local consumed = ally:GetMaxHealth() - ally:GetHealth()
									ally:HealEvent(consumed, self:GetAbility(), caster)
									local particle2 = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_lifestrike_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
									ParticleManager:SetParticleControlEnt(particle2, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true) 
									ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
									ParticleManager:ReleaseParticleIndex(particle2)
									spreadheal = heal - consumed
								else
									ally:HealEvent(spreadheal, self:GetAbility(), caster)
									local particle2 = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_lifestrike_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
									ParticleManager:SetParticleControlEnt(particle2, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true) 
									ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
									ParticleManager:ReleaseParticleIndex(particle2)
									break
								end
							end
						else
							break
						end
					end
				else
					caster:HealEvent(heal, self:GetAbility(), caster)
					local particle = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_lifestrike_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
					ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
					ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(particle)
				end

				self.hitUnits[target:entindex()] = true
			end
		end
		return true
	end--projectilehit

	if self:GetCaster():HasTalent("wraith_life_strike_talent_1") then
		local strikes = 8
		local angleVel = ToRadians(360/strikes)
		for i = 1, strikes do
			vDir = RotateVector2D(vDir, angleVel)
			velocity = vDir * speed
			ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = projectileFX,
																  position = caster:GetAbsOrigin(),
																  caster = caster,
																  ability = self,
																  speed = speed,
																  radius = width,
																  velocity = velocity,
																  duration = 10,
																  distance = distance,
																  hitUnits = {},
																  damage = damage})
		end
	else
		ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = projectileFX,
																  position = caster:GetAbsOrigin(),
																  caster = caster,
																  ability = self,
																  speed = speed,
																  radius = width,
																  velocity = velocity,
																  duration = 10,
																  distance = distance,
																  hitUnits = {},
																  damage = damage})
	end	
end
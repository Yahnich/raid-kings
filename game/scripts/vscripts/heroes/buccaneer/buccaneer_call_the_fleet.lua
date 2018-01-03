buccaneer_call_the_fleet = class({})
LinkLuaModifier( "modifier_call_the_fleet_ally", "heroes/buccaneer/buccaneer_call_the_fleet.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_call_the_fleet_ally_damage", "heroes/buccaneer/buccaneer_call_the_fleet.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_call_the_fleet:OnSpellStart()
	caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster:GetAbsOrigin()) * Vector(1,1,0)

	local ghostship_distance = self:GetSpecialValueFor("ghostship_distance")
	
	local ghostship_time = 3.1
	local ghostship_speed = ghostship_distance/ghostship_time
	ghostship_width = 425

	nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nFXIndex,0,caster:GetAbsOrigin() + caster:GetForwardVector() * ghostship_distance/2)
	ParticleManager:SetParticleControl(nFXIndex,2,Vector(ghostship_width,ghostship_width,1))

	local backwardVec = caster:GetAbsOrigin() - self:GetCursorPosition()
	backwardVec = backwardVec:Normalized()

	EmitSoundOn("Ability.Ghostship.bell",caster)
	EmitSoundOn("Ability.Ghostship",caster)

	local ProjectileHit = function(self, target, position)
		local buff_duration = self:GetAbility():GetSpecialValueFor("buff_duration")
		local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
		local ghostship_damage = self:GetAbility():GetSpecialValueFor("ghostship_damage")

		if not target then
			EmitSoundOnLocationWithCaster(position, "Ability.Ghostship.crash", caster)
			local enemies = caster:FindEnemyUnitsInRadius(position, ghostship_width, {})
			for _, enemy in pairs(enemies) do
				if not self.hitUnits[enemy:entindex()] then
					self:GetAbility():DealDamage(caster, enemy, ghostship_damage, {}, 0)
					enemy:AddNewModifier(caster, self:GetAbility(), "modifier_stunned_generic", {Duration=stun_duration})
					if enemy:HasModifier("modifier_buccaneer_jolly_roger") then
						Timers:CreateTimer(stun_duration, function()
							enemy:AddNewModifier(caster, self:GetAbility(), "modifier_dazed_generic", {Duration=stun_duration})
						end)
					end
					self.hitUnits[enemy:entindex()] = true
				end
			end
			ParticleManager:DestroyParticle(nFXIndex, false)
			ParticleManager:ReleaseParticleIndex(nFXIndex)
			return
		end

		if target ~= nil and not self.hitUnits[target:entindex()] and target:GetTeam() == caster:GetTeam() then
			target:AddNewModifier(caster, self:GetAbility(), "modifier_call_the_fleet_ally", {Duration=buff_duration})
			self.hitUnits[target:entindex()] = true
		end
		return true
	end--projectilehit

	ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = "particles/heroes/buccaneer/buccaneer_call_the_fleet_ship.vpcf",
																  position = caster:GetAbsOrigin() + (ghostship_distance/2 * backwardVec),
																  caster = caster,
																  ability = self,
																  speed = ghostship_speed,
																  radius = ghostship_width,
																  velocity = direction * ghostship_speed,
																  duration = 10,
																  distance = ghostship_distance,
																  hitUnits = {}})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_call_the_fleet_ally = class({})

function modifier_call_the_fleet_ally:OnCreated(table)
	self.incDamage = 0
end

function modifier_call_the_fleet_ally:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_call_the_fleet_ally:GetStatusEffectName()
	return "particles/status_fx/status_effect_rum.vpcf"
end

function modifier_call_the_fleet_ally:StatusEffectPriority()
	return 10
end

function modifier_call_the_fleet_ally:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end

function modifier_call_the_fleet_ally:GetModifierIncomingDamage_Percentage(params)
	return self:GetSpecialValueFor("ghostship_absorb")
end

function modifier_call_the_fleet_ally:OnTakeDamage(params)
	if params.attacker ~= self:GetCaster():GetTeam() and params.unit == self:GetParent() then
		local damageReduced = params.original_damage - params.damage
		self.incDamage = self.incDamage + damageReduced
	end
end

function modifier_call_the_fleet_ally:OnRemoved()
	if self.incDamage > 0 then
		local damage = self.incDamage
		self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_call_the_fleet_ally_damage",{Duration=10, damage=damage})
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_call_the_fleet_ally_damage = class({})

function modifier_call_the_fleet_ally_damage:OnCreated(table)
	if IsServer() then
		self.damage = table.damage or 0
		self:StartIntervalThink(self:GetDuration()/10)
	end
end

function modifier_call_the_fleet_ally_damage:OnIntervalThink()
	if IsServer() then
		self:GetParent():ModifyHealth(self:GetParent():GetHealth() - self.damage/10,self:GetAbility(),false,0)
	end
end

function modifier_call_the_fleet_ally_damage:GetTotalDamage()
	return (self:GetParent():GetHealth() - self.damage/10)*self:GetRemainingTime()
end

function modifier_call_the_fleet_ally_damage:IsDebuff()
	return true
end
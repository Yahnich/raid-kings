buccaneer_wavebreaker = class({})
LinkLuaModifier( "modifier_wavebreaker_slow", "heroes/buccaneer/buccaneer_wavebreaker.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_wavebreaker:OnSpellStart()
	local caster = self:GetCaster()
	local castPoint = self:GetCursorPosition()
	local direction = CalculateDirection(castPoint, caster:GetAbsOrigin())
	local distance = self:GetSpecialValueFor("wave_distance")
	radius = self:GetSpecialValueFor("wave_radius")
	local speed = 1000

	EmitSoundOn("Hero_Kunkka.Tidebringer.Attack", caster)

	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		if velocity.z > 0 then velocity.z = 0 end
		self:SetPosition( position + (velocity*FrameTime()) )
		
		local units = self:GetCaster():FindEnemyUnitsInRadius(position, radius, {})
		for _,unit in pairs(units) do
			if unit:HasModifier("modifier_buccaneer_jolly_roger") then
				unit:SetAbsOrigin(position)
			end
		end
	end--projectilethink

	local ProjectileHit = function(self, target, position)
		if target ~= nil and target:GetTeam() ~= self:GetCaster():GetTeam() then
			if not self.hitUnits[target:entindex()] then
				EmitSoundOn("Hero_Kunkka.TidebringerDamage", target)
				self:GetAbility():DealDamage(self:GetCaster(), target, self:GetCaster():GetAttackDamage()+self:GetAbility():GetSpecialValueFor("base_damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				if not target:HasModifier("modifier_buccaneer_jolly_roger") then
					target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wavebreaker_slow", {Duration = self:GetAbility():GetSpecialValueFor("duration")})
				end
				self.hitUnits[target:entindex()] = true
			end
		elseif not target then
			local units = self:GetCaster():FindEnemyUnitsInRadius(position, radius, {})
			for _,unit in pairs(units) do
				if unit:HasModifier("modifier_buccaneer_jolly_roger") then
					FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
				end
			end
		end
		return true
	end--projectilehit

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/buccaneer/buccaneer_wavebreaker.vpcf",
																  position = caster:GetAbsOrigin(),
																  caster = caster,
																  ability = self,
																  speed = speed,
																  radius = radius,
																  velocity = direction * speed,
																  duration = 10,
																  distance = distance,
																  hitUnits = {}})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_wavebreaker_slow = class({})

function modifier_wavebreaker_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return funcs
end

function modifier_wavebreaker_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("move_slow")
end

function modifier_wavebreaker_slow:GetModifierMiss_Percentage()
	return self:GetSpecialValueFor("miss_chance")
end

function modifier_wavebreaker_slow:IsDebuff()
	return true
end

function modifier_wavebreaker_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_rum.vpcf"
end

function modifier_wavebreaker_slow:StatusEffectPriority()
	return 10
end

function modifier_wavebreaker_slow:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end
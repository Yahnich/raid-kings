shinigami_fan_the_blades = class({})
LinkLuaModifier("modifier_shinigami_fan_the_blades_slow", "heroes/shinigami/shinigami_fan_the_blades.lua", 0)
LinkLuaModifier("modifier_shinigami_fan_the_blades_bonusdamage", "heroes/shinigami/shinigami_fan_the_blades.lua", 0)

function shinigami_fan_the_blades:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function shinigami_fan_the_blades:GetAOERadius()
	return 400
end

function shinigami_fan_the_blades:OnSpellStart()
	local caster = self:GetCaster()
	local speed = 1200
	local projectileLife = 10

	local dmgPct = self:GetSpecialValueFor("damage_bonus") / 100
	local baseDamage = self:GetTalentSpecialValueFor("base_damage")
	local bonusDamage = caster:GetAverageTrueAttackDamage(caster) * dmgPct + baseDamage
	
	local startPos = caster:GetAbsOrigin()
	local endPos = self:GetCursorPosition()
	local enemies = caster:FindEnemyUnitsInRadius(endPos, 400, {flag = DOTA_UNIT_TARGET_FLAG_NO_INVIS})
	local counter = self:GetSpecialValueFor("dagger_count")
	for _, enemy in pairs(enemies) do
		if counter > 1 then
			local direction = CalculateDirection(enemy, caster)
			local vVelocity = direction * speed * FrameTime()
			
			local ProjectileThink = function(self)
				local position = self:GetPosition()
				local velocity = self:GetVelocity()
				local speed = self:GetSpeed()
				velocity = CalculateDirection(enemy, position) * speed * FrameTime()
				if velocity:Length2D() ~= speed then velocity = velocity:Normalized() * speed end

				self:SetVelocity(velocity)
				self:SetPosition( GetGroundPosition(position, nil) + Vector(0,0,128) + velocity*FrameTime() )
				
			end	--projectileThink

			local ProjectileHit = function(self, target, position)
				if not target then return end
				if target == enemy and target:GetTeam() ~= caster:GetTeam() then
					if not self.hitUnits[target:entindex()] then
						local caster = self:GetCaster()
						caster:AddNewModifier(caster, self:GetAbility(), "modifier_shinigami_fan_the_blades_bonusdamage", {}):SetStackCount(baseDamage)
						caster:PerformAbilityAttack(target, true, self:GetAbility())
						caster:RemoveModifierByName("modifier_shinigami_fan_the_blades_bonusdamage")
						if caster:HasTalent("shinigami_fan_the_blades_talent_1") then
							target:AddNewModifier(caster, self:GetAbility(), "modifier_stunned_generic", {duration = 0.4})
						end

						-- apply slow
						target:AddNewModifier(caster, self:GetAbility(), "modifier_shinigami_fan_the_blades_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
						
						EmitSoundOn("Hero_PhantomAssassin.Dagger.Target", target)
						self.hitUnits[target:entindex()] = true
					end
				end
			end --projectilehit

			ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
																		  position = caster:GetAbsOrigin(),
																		  caster = caster,
																		  ability = self,
																		  speed = self:GetSpecialValueFor("dagger_speed"),
																		  radius = 10,
																		  velocity = vVelocity,
																		  duration = projectileLife,
																		  hitUnits = {}})

			counter = counter - 1
		end
	end
	EmitSoundOn("Hero_PhantomAssassin.Dagger.Cast", caster)
end

---------------------------------------------------------------------------------
modifier_shinigami_fan_the_blades_slow = class({})

function modifier_shinigami_fan_the_blades_slow:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow_amount")
end

function modifier_shinigami_fan_the_blades_slow:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_shinigami_fan_the_blades_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

---------------------------------------------------------------------------------
modifier_shinigami_fan_the_blades_bonusdamage = class({})

function modifier_shinigami_fan_the_blades_bonusdamage:IsHidden()
	return true
end

function modifier_shinigami_fan_the_blades_bonusdamage:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			}
	return funcs
end

function modifier_shinigami_fan_the_blades_bonusdamage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
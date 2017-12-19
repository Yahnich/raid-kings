ifrit_blaze_geyser = class({})

function ifrit_blaze_geyser:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return "custom/ifrit_blaze_geyser_kindled"
	else
		return "custom/ifrit_blaze_geyser"
	end
end

function ifrit_blaze_geyser:GetAOERadius()
	return self:GetSpecialValueFor("geyser_attack_range")
end

function ifrit_blaze_geyser:OnSpellStart()
	local speed = 900
	local radius = self:GetTalentSpecialValueFor("geyser_attack_range")
	local pos = self:GetCursorPosition()

	local dummy = CreateModifierThinker( self:GetCaster(), self, "modifier_ifrit_blaze_geyser_thinker", {duration = self:GetTalentSpecialValueFor("geyser_duration")}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
	EmitSoundOn("Ability.PreLightStrikeArray", dummy)
	local bKindled = self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active")

	

	Timers:CreateTimer(self:GetSpecialValueFor("geyser_attack_rate"), function()
		
		if not dummy:IsNull() then
			local damage = self:GetSpecialValueFor("geyser_damage") + (self:GetCaster().selfImmolationDamageBonus or 0)
			local enemies = self:GetCaster():FindEnemyUnitsInRadius(dummy:GetAbsOrigin(), radius, {})

			for _, enemy in pairs(enemies) do
				local direction = CalculateDirection(enemy, dummy)
				local vVelocity = direction * speed * FrameTime()

				local ProjectileThink = function(self)
					local position = self:GetPosition()
					local velocity = self:GetVelocity()
					local speed = self:GetSpeed()
					if not enemy:IsNull() then
						velocity = CalculateDirection(enemy, position) * speed * FrameTime()
						if velocity:Length2D() ~= speed then velocity = velocity:Normalized() * speed end

						self:SetVelocity(velocity)
						self:SetPosition( GetGroundPosition(position, nil) + Vector(0,0,128) + velocity*FrameTime() )
					else
						self:Remove()
					end
				end	--projectileThink

				local ProjectileHit = function(self, target, position)
					if not target then return false end
					if target == enemy and target:GetTeam() ~= self:GetCaster():GetTeam() then
						if not self.hitUnits[target:entindex()] then
							self:GetAbility():DealDamage(self:GetCaster(), target, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
							if self:GetCaster():HasTalent("ifrit_blaze_geyser_talent_1") then
								local duration = self:GetCaster():FindSpecificTalentValue("ifrit_blaze_geyser_talent_1", "duration")
								target:AddNewModifier(self:GetCaster(), self, "modifier_ifrit_blaze_geyser_burn", {duration = duration})
							end
							self.hitUnits[target:entindex()] = true
						end
						EmitSoundOn("Hero_Jakiro.LiquidFire", target)
						return false
					end
				end --projectilehit

				EmitSoundOn("Hero_Jakiro.LiquidFire", dummy)

				ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/ifrit/ifrit_blaze_geyser_projectile.vpcf",
																			  position = dummy:GetAbsOrigin(),
																			  caster = self:GetCaster(),
																			  ability = self,
																			  speed = speed,
																			  radius = 25,
																			  velocity = vVelocity,
																			  duration = 5,
																			  hitUnits = {},
																			  damage = damage})
				if not bKindled then
					break
				end
			end

			if #enemies > 0 then EmitSoundOn("hero_jakiro.attack", dummy) end

			return self:GetSpecialValueFor("geyser_attack_rate")
		else
			return
		end
	end)
end

modifier_ifrit_blaze_geyser_thinker = class({})
LinkLuaModifier( "modifier_ifrit_blaze_geyser_thinker", "heroes/ifrit/ifrit_blaze_geyser.lua", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_ifrit_blaze_geyser_thinker:OnCreated(kv)
		self.nFXIndex = ParticleManager:CreateParticle( "particles/heroes/ifrit/ifrit_blaze_geyser.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetParent():GetOrigin() )
	end
	
	function modifier_ifrit_blaze_geyser_thinker:OnDestroy()
		ParticleManager:DestroyParticle(self.nFXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.nFXIndex)
		UTIL_Remove( self:GetParent() )
	end
end

LinkLuaModifier( "modifier_ifrit_blaze_geyser_burn", "heroes/ifrit/ifrit_blaze_geyser.lua", LUA_MODIFIER_MOTION_NONE )
modifier_ifrit_blaze_geyser_burn = class({})

function modifier_ifrit_blaze_geyser_burn:OnCreated()
	self.damage_over_time = self:GetCaster():FindTalentValue("modifier_ifrit_blaze_geyser_burn")
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function modifier_ifrit_blaze_geyser_burn:OnRefresh()
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("damage_over_time")
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
end

function modifier_ifrit_blaze_geyser_burn:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_ifrit_blaze_geyser_burn:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_blaze_geyser_burn:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_ifrit_blaze_geyser_burn:IsFireDebuff()
	return true
end
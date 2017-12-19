wraith_wraithfire = class({})
LinkLuaModifier( "modifier_wraith_wraithfire_dot", "heroes/wraith/wraith_wraithfire.lua" ,LUA_MODIFIER_MOTION_NONE )

function wraith_wraithfire:OnAbilityPhaseStart()
	self.warmUp = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_wraithfire_warmup.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.warmUp, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	return true
end

function wraith_wraithfire:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle(self.warmUp ,false)
	ParticleManager:ReleaseParticleIndex(self.warmUp)
end

function wraith_wraithfire:OnSpellStart()
	ParticleManager:DestroyParticle(self.warmUp ,false)
	ParticleManager:ReleaseParticleIndex(self.warmUp)
	local caster = self:GetCaster()
	local abiltarget = self:GetCursorTarget()
	local direction = CalculateDirection(abiltarget, caster)

	local radius = self:GetTalentSpecialValueFor("blast_dot_radius")
	blast_damage = self:GetTalentSpecialValueFor("blast_damage")

	local speed = 1000

	local projectileLife = 15

	local vVelocity = direction * speed * FrameTime()
	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		local speed = self:GetSpeed()
		velocity = CalculateDirection(abiltarget, position) * speed * FrameTime()
		if velocity:Length2D() ~= speed then velocity = velocity:Normalized() * speed end

		self:SetVelocity(velocity)
		self:SetPosition( GetGroundPosition(position, nil) + Vector(0,0,128) + velocity*FrameTime() )
		
	end	--projectileThink

	local ProjectileHit = function(self, target, position)
		if not target then return end
		if target == abiltarget and target:GetTeam() ~= self:GetCaster():GetTeam() then
			if not self.hitUnits[target:entindex()] then
				EmitSoundOn("Hero_SkeletonKing.Hellfire_BlastImpact", target)
				local caster = self:GetCaster()
				
				self:GetAbility():DealDamage(caster, target, blast_damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				
				local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {})
				local duration = self:GetAbility():GetSpecialValueFor("blast_dot_duration")
				target:AddNewModifier(caster, self:GetAbility(), "modifier_stunned_generic", {duration = self:GetAbility():GetSpecialValueFor("blast_stun_duration")})
				for _, enemy in pairs(enemies) do
					enemy:AddNewModifier(caster, self:GetAbility(), "modifier_wraith_wraithfire_dot", {duration = duration})
				end
				local explosion = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_wraithfire_explosion_2.vpcf", PATTACH_POINT_FOLLOW, target)
					ParticleManager:SetParticleControl(explosion, 1, Vector(radius,0,0))
					--ParticleManager:SetParticleControl(explosion, 3, target:GetAbsOrigin())
					ParticleManager:SetParticleControlEnt(explosion, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(explosion)
				self.hitUnits[target:entindex()] = true
			end
			return false
		else
			return true
		end
	end --projectilehit

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/wraith/wraith_wraithfire.vpcf",
																  position = caster:GetAbsOrigin(),
																  caster = caster,
																  ability = self,
																  speed = speed,
																  radius = 10,
																  velocity = vVelocity,
																  duration = projectileLife,
																  hitUnits = {},
																  damage = blast_damage})
	EmitSoundOn("Hero_SkeletonKing.Hellfire_Blast", self:GetCaster())
end

modifier_wraith_wraithfire_dot = class({})

function modifier_wraith_wraithfire_dot:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("blast_dot_damage")
	self.slow = self:GetAbility():GetSpecialValueFor("blast_slow")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_wraith_wraithfire_dot:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_wraith_wraithfire_dot:GetTotalDamage()
	return self.damage*self:GetRemainingTime()
end

function modifier_wraith_wraithfire_dot:GetEffectName()
	return "particles/heroes/wraith/wraith_wraithfire_debuff.vpcf"
end

function modifier_wraith_wraithfire_dot:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_HEALING
			}
	return funcs
end

function modifier_wraith_wraithfire_dot:GetDisableHealing()
	if self:GetCaster():HasTalent("wraith_wraithfire_talent_1") then return 1 end
end

function modifier_wraith_wraithfire_dot:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
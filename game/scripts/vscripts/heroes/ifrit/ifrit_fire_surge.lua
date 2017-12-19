ifrit_fire_surge = class({})

--------------------------------------------------------------------------------
function ifrit_fire_surge:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ifrit_kindled_soul_active") then
		return "custom/ifrit_fire_surge_kindled"
	else
		return "custom/ifrit_fire_surge"
	end
end

function ifrit_fire_surge:OnSpellStart()
	local caster = self:GetCaster()

	self.speed = self:GetTalentSpecialValueFor( "speed" )
	self.width_initial = self:GetTalentSpecialValueFor( "width_initial" )
	self.width_end = self:GetTalentSpecialValueFor( "width_end" )
	self.distance = self:GetTalentSpecialValueFor( "distance" )
	
	self:GetCaster().selfImmolationDamageBonus = self:GetCaster().selfImmolationDamageBonus or 0
	self.maxDamage = self:GetTalentSpecialValueFor( "max_damage" ) + self:GetCaster().selfImmolationDamageBonus
	self.minDamage = self:GetTalentSpecialValueFor( "min_damage" ) + self:GetCaster().selfImmolationDamageBonus / 2
	
	self.projectileTable = {}
	currentdamage = self.maxDamage

	EmitSoundOn( "Hero_Lina.DragonSlave.Cast", caster )

	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetOrigin()
	else
		vPos = self:GetCursorPosition()
	end

	local vDirection = CalculateDirection(vPos, caster:GetOrigin())
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	self.speed = self.speed * ( self.distance / ( self.distance - self.width_initial ) )
	self.damage_falloff = (self.maxDamage - self.minDamage) * (self.distance / self.speed) * FrameTime()
	self:CreateFireSurge(vDirection)
	if caster:HasModifier("modifier_ifrit_kindled_soul_active") then
		for i = 1, self:GetTalentSpecialValueFor( "kindled_total_surges" ) do
			self:UseResources(true, false, false)
			local newDir = RotateVector2D(vDirection, 0.261799 * math.ceil(i/2) * (-1)^i)
			self:CreateFireSurge(newDir)
		end
	end
	EmitSoundOn( "Hero_Lina.DragonSlave", caster )
end

function ifrit_fire_surge:CreateFireSurge(vDirection)
	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		if velocity.z > 0 then velocity.z = 0 end
		self:SetPosition( position + (velocity*FrameTime()) )
		if not self:GetCaster():HasTalent("ifrit_fire_surge_talent_1") then
			--self:GetAbility().projectileTable[projectileID] = self:GetAbility().maxDamage
			if currentdamage > self:GetAbility().minDamage then
				currentdamage = currentdamage - self:GetAbility().damage_falloff
			elseif currentdamage < self:GetAbility().minDamage then
				currentdamage = self:GetAbility().minDamage
			end
		else
			currentdamage = self:GetAbility().maxDamage
		end
		--print(currentdamage)
	end--projectilethink

	local ProjectileHit = function(self, target, position)
		if not target then return end
		if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:IsInvulnerable() ) and target:GetTeam() ~= self:GetCaster():GetTeam() then
			--currentdamage = currentdamage or self:GetAbility().maxDamage
			if not self.hitUnits[target:entindex()] then
				self:GetAbility():DealDamage(self:GetCaster(), target, currentdamage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_ifrit_fire_surge_fire_debuff", { duration = self:GetAbility():GetSpecialValueFor("dot_duration"), damage = currentdamage * self:GetAbility():GetSpecialValueFor("dot_dmg_pct") / 100} )
				local vDirection = position - self:GetCaster():GetOrigin()
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
				ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
				self.hitUnits[target:entindex()] = true
			end
		end
		--self:GetAbility().projectileTable[projectileID] = nil -- clear memory space
		return true
	end--projectilehit

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/ifrit/ifrit_fire_surge_2_base.vpcf",
																  position = self:GetCaster():GetAbsOrigin(),
																  caster = self:GetCaster(),
																  ability = self,
																  speed = self.speed,
																  radius = self.width_initial,
																  velocity = vDirection * self.speed,
																  duration = 10,
																  distance = self.distance,
																  hitUnits = {},
																  damage = currentdamage})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_ifrit_fire_surge_fire_debuff", "heroes/ifrit/ifrit_fire_surge.lua", LUA_MODIFIER_MOTION_NONE )
modifier_ifrit_fire_surge_fire_debuff = class({})

function modifier_ifrit_fire_surge_fire_debuff:OnCreated(kv)
	self.damage_over_time = tonumber(kv.damage)
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = (self.damage_over_time or 0) * 2 end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function modifier_ifrit_fire_surge_fire_debuff:OnRefresh(kv)
	self.damage_over_time = tonumber(kv.damage)
	if self:GetCaster():HasScepter() then self.damage_over_time = (self.damage_over_time or 0) * 2 end
end

function modifier_ifrit_fire_surge_fire_debuff:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_ifrit_fire_surge_fire_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ifrit_fire_surge_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_ifrit_fire_surge_fire_debuff:IsFireDebuff()
	return true
end
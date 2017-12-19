revenant_penumbra = class({})
LinkLuaModifier( "modifier_penumbra", "heroes/revenant/revenant_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_penumbra:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	
	local speed = 500
	local radius = 200
	local distance = self:GetSpecialValueFor("range")
	
	EmitSoundOn("Hero_ShadowDemon.ShadowPoison.Cast", caster)

	--local nCounter = 0
	
	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		local speed = self:GetSpeed()
		local caster = self:GetCaster()
		if velocity.z > 0 then velocity.z = 0 end
		local homeEnemies = caster:FindEnemyUnitsInRadius(position, self:GetRadius() * 5, {order = FIND_CLOSEST})
		for _, enemy in ipairs(homeEnemies) do
			velocity = velocity + CalculateDirection(enemy, position) * speed * FrameTime()
			if velocity:Length2D() ~= speed then velocity = velocity:Normalized() * speed end
			break
		end
		self:SetVelocity(velocity)
		self:SetPosition( position + (velocity*FrameTime()) )
	end	
	
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		if not target then return end
		if not self.hitUnits[target:entindex()] then
			if target:IsAlive() and target:GetTeam() ~= caster:GetTeam() then
				EmitSoundOn("Hero_ShadowDemon.ShadowPoison.Impact", target)
				local nFX = ParticleManager:CreateParticle("particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_shadow_poison_release.vpcf", PATTACH_POINT_FOLLOW, target)
				ParticleManager:SetParticleControlEnt( nFX, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nFX, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )

				ParticleManager:ReleaseParticleIndex(nFX)
				target:AddNewModifier(caster, self:GetAbility(), "modifier_penumbra", {Duration = duration}):IncrementStackCount()

				if target:HasModifier("modifier_penumbra") then
					self:GetAbility():DealDamage(caster, target, damage*(target:FindModifierByName("modifier_penumbra"):GetStackCount()+1), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				else
					self:GetAbility():DealDamage(caster, target, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				end

				self.hitUnits[target:entindex()] = true
			end
		end
		return true
	end
	
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/revenant/revenant_penumbra.vpcf",
																		  position = caster:GetAbsOrigin(),
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = radius,
																		  velocity = speed * direction,
																		  distance = distance,
																		  hitUnits = {}
																		  })
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_penumbra = class({})

function modifier_penumbra:OnCreated(table)
	self.damage = self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("duration")

	self.caster = self:GetCaster()
	self.target = self:GetParent()

	if IsServer() then
		self.nCounter = ParticleManager:CreateParticle("particles/heroes/revenant/revenant_penumbra_stack_counter.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
		ParticleManager:SetParticleControlEnt(self.nCounter, 0, self.target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl(self.nCounter, 1, Vector(0,self:GetStackCount()+1,0))
	end
end

function modifier_penumbra:OnRefresh(table)
	if IsServer() then
		self.stackCount = self:GetStackCount() + 1
		if self.stackCount < 10 then
			ParticleManager:DestroyParticle(self.nCounter, true)
			self.nCounter = ParticleManager:CreateParticle("particles/heroes/revenant/revenant_penumbra_stack_counter.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
			ParticleManager:SetParticleControlEnt(self.nCounter, 0, self.target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true )
			ParticleManager:SetParticleControl(self.nCounter, 1, Vector(0,self.stackCount,0))
		else
			ParticleManager:DestroyParticle(self.nCounter, true)
			self.nCounter = ParticleManager:CreateParticle("particles/heroes/revenant/revenant_penumbra_stack_counter.vpcf", PATTACH_OVERHEAD_FOLLOW, self.target)
			ParticleManager:SetParticleControlEnt(self.nCounter, 0, self.target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true )
			ParticleManager:SetParticleControl(self.nCounter, 1, Vector(math.floor(self.stackCount/10),self.stackCount%10,0))
		end
	end
end

function modifier_penumbra:OnDestroy()
	if IsServer() then
		self:GetAbility():DealDamage(self.caster, self.target, self.damage*self:GetStackCount(), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		ParticleManager:DestroyParticle(self.nCounter, true)

		local nFX = ParticleManager:CreateParticle("particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_shadow_poison_kill.vpcf", PATTACH_POINT_FOLLOW, self.target)
		ParticleManager:SetParticleControlEnt( nFX, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFX, 2, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl(nFX, 3, Vector(50,0,0))
		ParticleManager:ReleaseParticleIndex(nFX)
	end
end

function modifier_penumbra:IsDebuff()
	return true
end
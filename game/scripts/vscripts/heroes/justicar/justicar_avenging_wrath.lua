justicar_avenging_wrath = class({})
LinkLuaModifier("modifier_justicar_avenging_wrath_debuff", "heroes/justicar/justicar_avenging_wrath.lua", 0)

function justicar_avenging_wrath:GetCastRange(vLoc, hUnit)
	return self:GetSpecialValueFor("distance")
end

function justicar_avenging_wrath:OnSpellStart()
	local hCaster = self:GetCaster()
	local vTarget = self:GetCursorPosition()
	
	local vDir = CalculateDirection(vTarget, hCaster) * Vector(1,1,0)
	local fVelocity = self:GetSpecialValueFor("speed")
	local fWidth = self:GetSpecialValueFor("width")
	local fDistance = self:GetSpecialValueFor("distance")
	
	local beams = self:GetTalentSpecialValueFor("beams")
	local angleOffSet = math.pi * 2 / beams
	for i = 1, beams do
		local newDir = RotateVector2D(vDir, angleOffSet * i)
		self:CreateWave(newDir, fVelocity, fWidth, fDistance)
	end
end

function justicar_avenging_wrath:CreateWave(vDir, fVelocity, fWidth, fDistance)
	local hCaster = self:GetCaster()
	local projPos = hCaster:GetAbsOrigin()
	local avenging_wrath = ParticleManager:CreateParticle( "particles/heroes/justicar/justicar_avenging_wrath.vpcf", PATTACH_POINT, hCaster )
	
    ParticleManager:SetParticleControlEnt( avenging_wrath, 0, hCaster, PATTACH_POINT, "attach_hitloc", hCaster:GetAbsOrigin(), true )
	EmitSoundOn("Hero_Chen.TestOfFaith.Cast", hCaster)
	
	
	local traveled = 0
	local speed = fVelocity * FrameTime()

	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		if velocity.z > 0 then velocity.z = 0 end
		self:SetPosition( position + (velocity*FrameTime()) )
		
		traveled = traveled + speed
		if traveled < fDistance then
			projPos = projPos + (vDir * speed)
			ParticleManager:SetParticleControl( avenging_wrath, 1, projPos )
			--[[
			local enemies = hCaster:FindEnemyUnitsInLine(hCaster:GetAbsOrigin(), projPos, fWidth, {})
			for _, enemy in pairs(enemies) do
				self:GetAbility():DealDamage(hCaster, enemy, 10, {}, 0)
				
				enemy:AddNewModifier(hCaster, self:GetAbility(), "modifier_justicar_avenging_wrath_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
				local hit = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", PATTACH_POINT_FOLLOW, enemy)
				ParticleManager:SetParticleControl(hit, 0, enemy:GetAbsOrigin())
				ParticleManager:SetParticleControl(hit, 1, enemy:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(hit)
			end
			]]
		else
			ParticleManager:DestroyParticle( avenging_wrath, false )
			ParticleManager:ReleaseParticleIndex(avenging_wrath)
		end
	end--projectilethink

	local ProjectileHit = function(self, target, position)
		if not target then return end
		if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:IsInvulnerable() ) then
			if not self.hitUnits[target:entindex()] then
				--local innerSun = hCaster:GetInnerSun()
				--self:GetCaster():ResetInnerSun()
				self:GetAbility():DealDamage(hCaster, target, self:GetAbility():GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				
				target:AddNewModifier(hCaster, self:GetAbility(), "modifier_justicar_avenging_wrath_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
				local hit = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", PATTACH_POINT_FOLLOW, target)
				ParticleManager:SetParticleControl(hit, 0, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(hit, 1, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(hit)
				self.hitUnits[target:entindex()] = true
			end
		end
		return true
	end--projectilehit

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/justicar/justicar_avenging_wrath_projectile/justicar_avenging_wrath_projectile.vpcf",
																  position = projPos,
																  caster = hCaster,
																  ability = self,
																  speed = speed,
																  radius = fWidth,
																  velocity = vDir * fVelocity,
																  duration = 10,
																  distance = fDistance,
																  hitUnits = {}})
end

modifier_justicar_avenging_wrath_debuff = class({})


function modifier_justicar_avenging_wrath_debuff:OnCreated()
	self.miss = self:GetAbility():GetSpecialValueFor("miss_chance")
	self.amp = self:GetAbility():GetSpecialValueFor("damage_amp")
	self.Lifesteal = self:GetAbility():GetSpecialValueFor("Lifesteal")
end

function modifier_justicar_avenging_wrath_debuff:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MISS_PERCENTAGE
		}
		return funcs
	end

function modifier_justicar_avenging_wrath_debuff:GetModifierIncomingDamage_Percentage(params)
	if IsServer() then
		if params.attacker:GetTeam() == self:GetCaster():GetTeam() then
			params.attacker:Lifesteal(self.Lifesteal, params.damage)
		end
	end
	return self.amp
end

function modifier_justicar_avenging_wrath_debuff:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_justicar_avenging_wrath_debuff:GetEffectName()
	return "particles/heroes/justicar/justicar_avenging_wrath_debuff.vpcf"
end
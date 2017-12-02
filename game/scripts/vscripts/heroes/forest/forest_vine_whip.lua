forest_vine_whip = class({})

function forest_vine_whip:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local vDir = CalculateDirection( self:GetCursorPosition(), caster ) * Vector(1,1,1)
	
	local distance = self:GetTrueCastRange()
	local fVel = self:GetSpecialValueFor("speed")
	local speed = fVel * FrameTime()
	local width = self:GetSpecialValueFor("width")
	local damage = self:GetSpecialValueFor("damage")
	local stunDuration = self:GetSpecialValueFor("stun_duration")

	local projectilePos = caster:GetAbsOrigin()
	
	EmitSoundOn("Hero_Enchantress.EnchantCast", caster)
	
	local nFX = ParticleManager:CreateParticle("particles/heroes/forest/forest_vine_whip_projectile.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(nFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	
	local traveled = 0
	
	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		--if velocity.z > 0 then velocity.z = 0 end
		self:SetPosition( position + (velocity*FrameTime()) )
		
		traveled = traveled + speed
		if traveled < distance then
			projectilePos = projectilePos + (vDir * speed)
			ParticleManager:SetParticleControl( nFX, 3, projectilePos )
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
			ParticleManager:DestroyParticle( nFX, false )
			ParticleManager:ReleaseParticleIndex(nFX)
		end
	end--projectilethink

	local ProjectileHit = function(self, target, position)
		if not target then return end
		if target ~= nil then
			if not self.hitUnits[target:entindex()] then
				if target:GetTeam() ~= caster:GetTeam() then
					ability:DealDamage(caster, target, damage)
					target:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = stunDuration})
					EmitSoundOn("Hero_Enchantress.Untouchable", caster)
				elseif caster:HasTalent("forest_vine_whip_talent_1") and target:GetTeam() == caster:GetTeam() then
					ally:HealEvent(damage, ability, caster)
					ally:Dispel(caster, true)
					EmitSoundOn("Hero_Enchantress.Untouchable", caster)
				end
				self.hitUnits[target:entindex()] = true
			end
		end
		return true
	end--projectilehit

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/justicar/justicar_avenging_wrath_projectile/justicar_avenging_wrath_projectile.vpcf",
																  position = projectilePos+Vector(0,0,100),
																  caster = caster,
																  ability = self,
																  speed = speed,
																  radius = width,
																  velocity = vDir * fVel,
																  duration = 10,
																  distance = distance,
																  hitUnits = {}})
end


modifier_forest_vine_whip_talent_1 = class({IsHidden = function(self) return true end, RemoveOnDeath = function(self) return false end, AllowIllusionDuplicate = function(self) return true end})
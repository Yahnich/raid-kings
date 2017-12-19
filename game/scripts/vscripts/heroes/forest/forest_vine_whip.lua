forest_vine_whip = class({})

function forest_vine_whip:OnSpellStart()
	caster = self:GetCaster()
	ability = self
	vDir = CalculateDirection( self:GetCursorPosition(), caster ) * Vector(1,1,1)
	
	distance = self:GetTrueCastRange()
	local fVel = self:GetSpecialValueFor("speed")
	speed = fVel * FrameTime()
	local width = self:GetSpecialValueFor("width")
	damage = self:GetSpecialValueFor("damage")
	local stunDuration = self:GetSpecialValueFor("stun_duration")

	projectilePos = caster:GetAbsOrigin()
	
	EmitSoundOn("Hero_Enchantress.EnchantCast", caster)
	
	local nFX = ParticleManager:CreateParticle("particles/heroes/forest/forest_vine_whip_projectile.vpcf", PATTACH_POINT, caster)
	if RollPercentage(50) then
		ParticleManager:SetParticleControlEnt(nFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_beard", caster:GetAbsOrigin(), true)
	else
		ParticleManager:SetParticleControlEnt(nFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_beard_right", caster:GetAbsOrigin(), true)
	end
	
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
		else
			ParticleManager:DestroyParticle( nFX, false )
			ParticleManager:ReleaseParticleIndex(nFX)
		end
	end--projectilethink

	local ProjectileHit = function(self, target, position)
		if not target then return end
		if target ~= nil and target:GetTeam() ~= caster:GetTeam() then
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

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/forest/forest_vine_whip_projectile_projectile.vpcf",
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
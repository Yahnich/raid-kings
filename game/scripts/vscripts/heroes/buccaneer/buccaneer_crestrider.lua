buccaneer_crestrider = class({})
LinkLuaModifier( "modifier_crestrider", "heroes/buccaneer/buccaneer_crestrider.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_crestrider_enemy", "heroes/buccaneer/buccaneer_crestrider.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_crestrider:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_Morphling.Waveform", caster)
	caster:AddNewModifier(caster,self,"modifier_crestrider",{Duration = duration})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_crestrider = class({})

function modifier_crestrider:OnCreated(table)
	if IsServer() then
		self.wave_radius = self:GetSpecialValueFor("wave_radius")
		self:StartIntervalThink(0.01)
		self.nFX = ParticleManager:CreateParticle("particles/heroes/buccaneer/buccaneer_crestrider.vpcf",PATTACH_POINT_FOLLOW,self:GetCaster())
	end
end

function modifier_crestrider:OnIntervalThink()
	if IsServer() then
		self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 5)
		self:GetCaster():SetAbsOrigin(Vector(self:GetCaster():GetAbsOrigin().x, self:GetCaster():GetAbsOrigin().y, 200))
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self.wave_radius, {})
		for _,enemy in pairs(enemies) do
			enemy:SetAbsOrigin(self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 50)
			enemy:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_crestrider_enemy",{})
		end
		ParticleManager:SetParticleControl(self.nFX,3,GetGroundPosition(self:GetCaster():GetAbsOrigin(),self.caster))

		GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(),self.wave_radius,true)
	end
end

function modifier_crestrider:CheckState()
	local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_DISARMED] = true
					}
	return state
end

function modifier_crestrider:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetCaster(),self:GetCaster():GetAbsOrigin(),true)
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(),FIND_UNITS_EVERYWHERE,{})
		for _,enemy in pairs(enemies) do
			enemy:RemoveModifierByName("modifier_crestrider_enemy")
			FindClearSpaceForUnit(enemy,enemy:GetAbsOrigin(),true)
		end
		GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(),self.wave_radius,true)
		ParticleManager:DestroyParticle(self.nFX,false)
	end
end

function modifier_crestrider:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}
	return funcs
end

function modifier_crestrider:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_crestrider:GetOverrideAnimationRate()
	return 1.5
end

function modifier_crestrider:GetModifierTurnRate_Percentage()
	return -101
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_crestrider_enemy = class({})

function modifier_crestrider_enemy:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_crestrider_enemy:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_buccaneer_jolly_roger") then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("damage"), {}, 0)
	end
end

function modifier_crestrider_enemy:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					--[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					}
	return state
end

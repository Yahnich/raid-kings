avalanche_arcane_blizzard = class({})
LinkLuaModifier( "modifier_arcane_blizzard", "heroes/avalanche/avalanche_arcane_blizzard.lua" ,LUA_MODIFIER_MOTION_NONE )

function avalanche_arcane_blizzard:GetAOERadius()
	return self:GetSpecialValueFor("storm_radius")
end

function avalanche_arcane_blizzard:GetChannelTime()
	return self:GetSpecialValueFor("channel_time")
end

function avalanche_arcane_blizzard:GetChannelAnimation()
	return "ACT_DOTA_CAST_ABILITY_1"
end

function avalanche_arcane_blizzard:OnSpellStart()
	local caster = self:GetCaster()
	local castPoint = self:GetCursorPosition()
	local damage = self:GetSpecialValueFor("damage")/100
	local radius = self:GetSpecialValueFor("storm_radius")

	self.storm = ParticleManager:CreateParticle("particles/heroes/avalanche/avalanche_arcane_blizzard.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(self.storm, 0, castPoint)

	EmitSoundOnLocationWithCaster(castPoint, "hero_Crystal.freezingField.wind", caster)

	Timers:CreateTimer(0, function()
		if caster:IsChanneling() then
			local randoVect = Vector(RandomInt(-radius,radius), RandomInt(-radius,radius), 0)
			local casterRando = castPoint + randoVect

			local nfx = ParticleManager:CreateParticle("particles/heroes/avalanche/avalanche_arcane_blizzard_snowflake.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(nfx, 0, casterRando )
			ParticleManager:SetParticleControl(nfx, 1, casterRando )
			ParticleManager:ReleaseParticleIndex(nfx)

			Timers:CreateTimer(0.1, function()
				local units = caster:FindEnemyUnitsInRadius(casterRando, self:GetSpecialValueFor("icechunck_radius"), {})
				for _, unit in pairs(units) do
					if not unit:IsFrozenGeneric() then
						damage = caster:GetAverageTrueAttackDamage(unit)*damage/100							
						self:DealDamage(caster, unit, damage, {}, 0)
						for i=1,self:GetSpecialValueFor("chill_count") do
							unit:AddChill(self, caster, self:GetSpecialValueFor("chill_duration"))
						end
					end
				end
				GridNav:DestroyTreesAroundPoint(casterRando,self:GetSpecialValueFor("icechunck_radius"),false)
			end)
			return 0.1
		else
			ParticleManager:DestroyParticle(self.storm, false)
			return nil
		end
	end)
end

function avalanche_arcane_blizzard:OnChannelFinish(bInterrupted)
	ParticleManager:DestroyParticle(self.storm, false)
	StopSoundEvent("hero_Crystal.freezingField.wind", caster)
end
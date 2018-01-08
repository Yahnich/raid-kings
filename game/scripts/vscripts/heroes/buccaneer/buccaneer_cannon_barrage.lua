buccaneer_cannon_barrage = class({})
LinkLuaModifier( "modifier_cannon_ball_slow", "heroes/buccaneer/buccaneer_cannon_barrage.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cannon_ball_armor_remove", "heroes/buccaneer/buccaneer_cannon_barrage.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_cannon_barrage:OnSpellStart()
	local caster = self:GetCaster()
	local castPoint = self:GetCursorPosition()

	local duration = self:GetSpecialValueFor( "slow_duration" )
	local damage = self:GetSpecialValueFor( "damage" )
	local cannon_balls = self:GetSpecialValueFor( "cannon_balls" )
	local radius = self:GetSpecialValueFor( "radius" )

	local projectilesMax = cannon_balls
	local projectilesCurrent = 0

	EmitSoundOn("Ability.Ghostship.bell", caster)
	
	--EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Gyrocopter.CallDown.Damage", caster)
	Timers:CreateTimer(0, function()
		if projectilesCurrent < projectilesMax then
			local randoVect = Vector(RandomInt(-radius,radius), RandomInt(-radius,radius), 0)
			local casterRando = castPoint + randoVect

			local nfx = ParticleManager:CreateParticle("particles/heroes/buccaneer/buccaneer_cannon_barragefly.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(nfx, 0, casterRando + Vector(0,0,5000) )
			ParticleManager:SetParticleControl(nfx, 1, casterRando )
			ParticleManager:SetParticleControl(nfx, 2, Vector(1.5,0,0) )
			ParticleManager:ReleaseParticleIndex(nfx)

			Timers:CreateTimer(1.5, function()
				local units = caster:FindEnemyUnitsInRadius(casterRando, radius, {})
				for _, unit in pairs(units) do								
					self:DealDamage(caster, unit, damage, {}, 0)
					unit:AddNewModifier(caster,self,"modifier_cannon_ball_slow",{Duration = duration})

					if unit:HasModifier("modifier_buccaneer_jolly_roger") then
						unit:AddNewModifier(caster, self, "modifier_cannon_ball_armor_remove", {Duration=duration})
					end
				end
				GridNav:DestroyTreesAroundPoint(casterRando,radius,false)
				projectilesCurrent = projectilesCurrent + 1
				local nfx_2 = ParticleManager:CreateParticle("particles/heroes/buccaneer/buccaneer_cannon_barrage_scorch.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx_2, 0, casterRando )
				ParticleManager:ReleaseParticleIndex(nfx_2)
			end)
			return 0.25
		else
			return nil
		end
	end)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_cannon_ball_slow = class({})

function modifier_cannon_ball_slow:OnCreated(table)
	self.slow_amount = self:GetSpecialValueFor( "slow_amount" )
end

function modifier_cannon_ball_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_cannon_ball_slow:GetModifierMoveSpeedBonus_Percentage( params )
	return self.slow_amount
end

function modifier_cannon_ball_slow:IsDebuff()
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_cannon_ball_armor_remove = class({})
function modifier_cannon_ball_armor_remove:OnCreated(table)
	self.armor = self:GetParent():GetPhysicalArmorValue()*-1
end

function modifier_cannon_ball_armor_remove:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_cannon_ball_armor_remove:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_cannon_ball_armor_remove:IsDebuff()
	return true
end
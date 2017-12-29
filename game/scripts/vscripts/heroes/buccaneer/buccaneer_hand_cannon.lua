buccaneer_hand_cannon = class({})
LinkLuaModifier( "modifier_hand_cannon", "heroes/buccaneer/buccaneer_hand_cannon.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hand_cannon_slow", "heroes/buccaneer/buccaneer_hand_cannon.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_hand_cannon:OnSpellStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetAbsOrigin()
	local casterDirection = caster:GetForwardVector()

	local damage_multiplier = self:GetSpecialValueFor("damage_multiplier")
	local damage_multiplier = self:GetSpecialValueFor("damage_multiplier")
	local knock_back = self:GetSpecialValueFor("knock_back")

	StartAnimation(caster, {duration=1, activity=ACT_DOTA_ATTACK, rate=1.5, translate="tidebringer", translate2="Espada_pistola"})

	EmitSoundOn("Hero_Kunkka.InverseBayonet", caster)

	caster:AddNewModifier(caster,self,"modifier_hand_cannon",{})
	local distance = 0
	Timers:CreateTimer(0.3, function()

		local nFx2 = ParticleManager:CreateParticle("particles/econ/items/kunkka/kunkka_weapon_gunsword/kunkka_shot_gun.vpcf",PATTACH_POINT,caster)
		ParticleManager:ReleaseParticleIndex(nFx2)

		local nFx = ParticleManager:CreateParticle("particles/heroes/buccaneer/buccaneer_hand_cannon.vpcf",PATTACH_POINT,caster)
		ParticleManager:ReleaseParticleIndex(nFx)

		local enemies = FindUnitsInCone(caster:GetTeam(), casterDirection, casterPos, 250, 500, nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, true) 
		for _,enemy in pairs(enemies) do

			caster:PerformGenericAttack(enemy, true)
			self:DealDamage(caster, enemy, knock_back, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)

			enemy:AddNewModifier(caster,self,"modifier_hand_cannon",{})

			Timers:CreateTimer(0,function()
				distance = (enemy:GetAbsOrigin() - casterPos):Length2D()
				if enemy:HasModifier("modifier_buccaneer_jolly_roger") then
					if distance < knock_back*2 then
						enemy:SetAbsOrigin(enemy:GetAbsOrigin()+casterDirection*75)
						return FrameTime()
					else
						enemy:RemoveModifierByName("modifier_hand_cannon")
						FindClearSpaceForUnit(enemy,enemy:GetAbsOrigin(),true)
						return nil
					end
				else
					if distance < knock_back then
						enemy:SetAbsOrigin(enemy:GetAbsOrigin()+casterDirection*75)
						return FrameTime()
					else
						enemy:RemoveModifierByName("modifier_hand_cannon")
						FindClearSpaceForUnit(enemy,enemy:GetAbsOrigin(),true)
						return nil
					end
				end
			end)
		end
		Timers:CreateTimer(0,function()
			distance = (caster:GetAbsOrigin() - casterPos):Length2D()
			if distance < knock_back  then
				caster:SetAbsOrigin(caster:GetAbsOrigin()-casterDirection*50)
				return FrameTime()
			else
				caster:RemoveModifierByName("modifier_hand_cannon")
				FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
				return nil
			end
		end)
	end)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_hand_cannon = class({})

function modifier_hand_cannon:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					}
	return state
end

function modifier_hand_cannon:GetEffectName()
	return "particles/generic_ground_slide.vpcf"
end

function modifier_hand_cannon:IsHidden()
	return true
end

function modifier_hand_cannon:OnRemoved()
	if self:GetParent():HasModifier("modifier_buccaneer_jolly_roger") then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hand_cannon_slow", {Duration=self:GetSpecialValueFor("slow_duration")})
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_hand_cannon_slow = class({})

function modifier_hand_cannon_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_hand_cannon_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("slow")
end

function modifier_hand_cannon:IsDebuff()
	return true
end
buccaneer_captains_rum = class({})
LinkLuaModifier( "modifier_rum_stacks_counter", "heroes/buccaneer/buccaneer_captains_rum.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rum_stacks", "heroes/buccaneer/buccaneer_captains_rum.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rum", "heroes/buccaneer/buccaneer_captains_rum.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_captains_rum:GetIntrinsicModifierName()
	if self:IsTrained() then
		return "modifier_rum_stacks_counter"
	end
end

function buccaneer_captains_rum:OnUpgrade()
	if self:GetLevel() < 2 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rum_stacks", {}):SetStackCount(self:GetSpecialValueFor("max_bottles"))
	end
end

function buccaneer_captains_rum:OnSpellStart()
	local caster = self:GetCaster()
	local castTarget = self:GetCursorTarget()
	local castPoint = self:GetCursorPosition()

	EmitSoundOn("Hero_Brewmaster.DrunkenHaze.Cast", caster)

	if caster:FindModifierByName("modifier_rum_stacks") and caster:FindModifierByName("modifier_rum_stacks"):GetStackCount() > 0 then
		if castTarget then
			if castTarget:GetTeam() == caster:GetTeam() then
				if caster:FindModifierByName("modifier_rum_stacks"):GetStackCount() < 2 then
					caster:RemoveModifierByName("modifier_rum_stacks")
				else
					caster:FindModifierByName("modifier_rum_stacks"):DecrementStackCount()
				end
				castTarget:AddNewModifier(caster, self, "modifier_rum", {Duration=self:GetSpecialValueFor("drunk_duration")})
				EmitSoundOn("Hero_Brewmaster.DrunkenHaze.Target", castTarget)
			end
		else
			local allies = self:GetCaster():FindFriendlyUnitsInRadius(castPoint, FIND_UNITS_EVERYWHERE, {order=FIND_CLOSEST})
			for _,ally in pairs(allies) do
				if caster:FindModifierByName("modifier_rum_stacks"):GetStackCount() < 2 then
					caster:RemoveModifierByName("modifier_rum_stacks")
				else
					caster:FindModifierByName("modifier_rum_stacks"):DecrementStackCount()
				end
				ally:AddNewModifier(caster, self, "modifier_rum", {Duration=self:GetSpecialValueFor("drunk_duration")})
				EmitSoundOn("Hero_Brewmaster.DrunkenHaze.Target", ally)
				break
			end
		end
	elseif not caster:FindModifierByName("modifier_rum_stacks") then
		self:EndCooldown()
		self:RefundManaCost()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_rum_stacks_counter = class({})

function modifier_rum_stacks_counter:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetSpecialValueFor("recharge_rate"))
	end
end

function modifier_rum_stacks_counter:OnIntervalThink()
	if IsServer() then
		if not self:GetCaster():FindModifierByName("modifier_rum_stacks") or self:GetCaster():FindModifierByName("modifier_rum_stacks"):GetStackCount() < 3 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_rum_stacks", {}):IncrementStackCount()
		end

		if not self:GetCaster():FindModifierByName("modifier_rum_stacks") then
			self:GetAbility():SetActivated(false)
		else
			self:GetAbility():SetActivated(true)
		end
	end
end

function modifier_rum_stacks_counter:IsHidden()
	return true 
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_rum_stacks = class({})
function modifier_rum_stacks:IsDebuff()
	return false
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_rum = class({})
function modifier_rum:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_rum:OnAttackLanded(params)
	if params.attacker == self:GetParent() and params.attacker ~= self:GetCaster() then
		local ability = params.attacker:FindAbilityByName("buccaneer_jolly_roger")
		if params.target:HasModifier("modifier_buccaneer_jolly_roger") then
			params.attacker:ModifyGold(ability:GetSpecialValueFor( "gold" ),true,0)
			SendOverheadEventMessage(params.attacker:GetPlayerOwner(),OVERHEAD_ALERT_GOLD,params.attacker,ability:GetSpecialValueFor( "gold" ),params.attacker)
		elseif RollPercentage(ability:GetSpecialValueFor( "gold_chance" )) then
			params.attacker:ModifyGold(ability:GetSpecialValueFor( "gold" ),true,0)
			SendOverheadEventMessage(params.attacker:GetPlayerOwner(),OVERHEAD_ALERT_GOLD,params.attacker,ability:GetSpecialValueFor( "gold" ),params.attacker)
		end
	end
end

function modifier_rum:GetModifierMiss_Percentage()
	return self:GetSpecialValueFor("drunk_miss")
end

function modifier_rum:GetModifierDamageOutgoing_Percentage()
	return self:GetSpecialValueFor("drunk_damage")
end

function modifier_rum:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("drunk_speed")
end

function modifier_rum:GetStatusEffectName()
	return "particles/status_fx/status_effect_brewmaster_drunken_haze.vpcf"
end

function modifier_rum:StatusEffectPriority()
	return 10
end

function modifier_rum:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end

function modifier_rum:IsDebuff()
	return false
end
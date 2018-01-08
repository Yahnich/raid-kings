buccaneer_jolly_roger = class({})
LinkLuaModifier( "modifier_buccaneer_jolly_roger", "heroes/buccaneer/buccaneer_jolly_roger.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_buccaneer_jolly_roger_passive", "heroes/buccaneer/buccaneer_jolly_roger.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_jolly_roger:GetIntrinsicModifierName()
	return "modifier_buccaneer_jolly_roger_passive"
end

function buccaneer_jolly_roger:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor( "duration" )

	local units = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		unit:RemoveModifierByName("modifier_buccaneer_jolly_roger")
	end
	
	if target and not target:IsMagicImmune() then
		target:AddNewModifier(caster,self,"modifier_buccaneer_jolly_roger",{Duration=duration})
		EmitSoundOn("Ability.XMarksTheSpot.Target",target)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_buccaneer_jolly_roger_passive = class({})

function modifier_buccaneer_jolly_roger_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_buccaneer_jolly_roger_passive:OnAttackLanded(params)
	if params.attacker == self:GetCaster() then
		if params.target:HasModifier("modifier_buccaneer_jolly_roger") then
			self:GetCaster():ModifyGold(self:GetAbility():GetSpecialValueFor( "gold" ),true,0)
			SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(),OVERHEAD_ALERT_GOLD,self:GetCaster(),self:GetAbility():GetSpecialValueFor( "gold" ),self:GetCaster())
		elseif RollPercentage(self:GetAbility():GetSpecialValueFor( "gold_chance" )) then
			self:GetCaster():ModifyGold(self:GetAbility():GetSpecialValueFor( "gold" ),true,0)
			SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(),OVERHEAD_ALERT_GOLD,self:GetCaster(),self:GetAbility():GetSpecialValueFor( "gold" ),self:GetCaster())
		end
	end
end

function modifier_buccaneer_jolly_roger_passive:IsHidden()
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_buccaneer_jolly_roger = class({})

function modifier_buccaneer_jolly_roger:OnCreated( kv )
	self.unitOgPos = self:GetParent():GetAbsOrigin()
	self.caster = self:GetCaster()
	EmitSoundOn("Ability.XMark.Target_Movement",self:GetParent())
end

function modifier_buccaneer_jolly_roger:OnRemoved()
	if IsServer() then
		if self:GetRemainingTime() < 1 then
			FindClearSpaceForUnit(self:GetParent(),self.unitOgPos,true)
			StopSoundOn("Ability.XMark.Target_Movement",self:GetParent())
			EmitSoundOn("Ability.XMarksTheSpot.Return",self:GetParent())
		end
	end
end

function modifier_buccaneer_jolly_roger:GetEffectName()
	return "particles/heroes/buccaneer/buccaneer_x_marks.vpcf"
end

function modifier_buccaneer_jolly_roger:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_buccaneer_jolly_roger:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_buccaneer_jolly_roger:GetModifierIncomingPhysicalDamage_Percentage()
	return self:GetSpecialValueFor( "bonus_damage" )
end

function modifier_buccaneer_jolly_roger:IsDebuff()
	return true
end

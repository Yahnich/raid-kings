buccaneer_x_marks = class({})
LinkLuaModifier( "modifier_x_marks", "heroes/buccaneer/buccaneer_x_marks.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_x_marks_passive", "heroes/buccaneer/buccaneer_x_marks.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_x_marks:GetIntrinsicModifierName()
	return "modifier_x_marks_passive"
end

function buccaneer_x_marks:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor( "duration" )

	local units = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		unit:RemoveModifierByName("modifier_x_marks")
	end
	
	if target and not target:IsMagicImmune() then
		target:AddNewModifier(caster,self,"modifier_x_marks",{Duration=duration})
		EmitSoundOn("Ability.XMarksTheSpot.Target",target)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_x_marks_passive = class({})

function modifier_x_marks_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_x_marks_passive:OnAttackLanded(params)
	if params.attacker == self:GetCaster() then
		if params.target:HasModifier("modifier_x_marks") then
			self:GetCaster():ModifyGold(self:GetAbility():GetSpecialValueFor( "gold" ),true,0)
			SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(),OVERHEAD_ALERT_GOLD,self:GetCaster(),self:GetAbility():GetSpecialValueFor( "gold" ),self:GetCaster())
		elseif RollPercentage(self:GetAbility():GetSpecialValueFor( "gold_chance" )) then
			self:GetCaster():ModifyGold(self:GetAbility():GetSpecialValueFor( "gold" ),true,0)
			SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(),OVERHEAD_ALERT_GOLD,self:GetCaster(),self:GetAbility():GetSpecialValueFor( "gold" ),self:GetCaster())
		end
	end
end

function modifier_x_marks_passive:IsHidden()
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_x_marks = class({})

function modifier_x_marks:OnCreated( kv )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.unitOgPos = self:GetParent():GetAbsOrigin()
	self.caster = self:GetCaster()
	EmitSoundOn("Ability.XMark.Target_Movement",self:GetParent())
end

function modifier_x_marks:OnRemoved()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(),self.unitOgPos,true)
		StopSoundOn("Ability.XMark.Target_Movement",self:GetParent())
		EmitSoundOn("Ability.XMarksTheSpot.Return",self:GetParent())
	end
end

function modifier_x_marks:GetEffectName()
	return "particles/heroes/buccaneer/buccaneer_x_marks.vpcf"
end

function modifier_x_marks:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_x_marks:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_x_marks:GetModifierIncomingDamage_Percentage()
	return self.bonus_damage
end

function modifier_x_marks:IsDebuff()
	return true
end

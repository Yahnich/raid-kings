revenant_shade_walk = class({})
LinkLuaModifier( "modifier_shade_walk", "heroes/revenant/revenant_shade_walk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shade_walk_slow", "heroes/revenant/revenant_shade_walk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_clone", "libraries/modifiers/modifier_shadow_clone.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_shade_walk:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")
	local illusion_damage_dealt = self:GetSpecialValueFor("illusion_damage_dealt")
	local illusion_damage_taken = self:GetSpecialValueFor("illusion_damage_taken")

	EmitSoundOn("Hero_Clinkz.WindWalk", caster)

	caster:AddNewModifier(caster, self, "modifier_shade_walk", {Duration=duration})
	caster:AddNewModifier(self:GetCaster(), self, "modifier_invisibility_custom", {duration=duration})

	local shadowling = self:GetCaster():CreateSummon(caster:GetUnitName(), caster:GetAbsOrigin(), illusion_duration)
	shadowling:AddNewModifier(self:GetCaster(), self, "modifier_shadow_clone", {duration=duration, incomingdamage=illusion_damage_taken , outgoingdamage=illusion_damage_dealt})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_shade_walk = class({})

function modifier_shade_walk:OnCreated(table)
	if IsServer() then
		self:GetCaster():SetRenderColor(0, 0, 0)
	end
end

function modifier_shade_walk:IsAura()
	return true
end

function modifier_shade_walk:GetAuraDuration()
	return self:GetSpecialValueFor("slow_duration")
end

function modifier_shade_walk:GetAuraEntityReject(hEntity)
	return hEntity == self:GetCaster()
end

function modifier_shade_walk:GetAuraRadius()
	return self:GetSpecialValueFor("radius")
end

function modifier_shade_walk:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_shade_walk:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_shade_walk:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_shade_walk:GetModifierAura()
	return "modifier_shade_walk_slow"
end

function modifier_shade_walk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_shade_walk:CheckState()
	local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
				}
	return state
end

function modifier_shade_walk:GetEffectName()
	return "particles/items2_fx/smoke_of_deceit_buff.vpcf"
end

function modifier_shade_walk:GetModifierMoveSpeedBonus_Percentage(params)
	return self:GetSpecialValueFor("move_speed")
end

function modifier_shade_walk:OnRemoved()
	if IsServer() then
		self:GetCaster():SetRenderColor(255, 255, 255)
	end
end

function modifier_shade_walk:IsDebuff()
	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_shade_walk_slow = class({})

function modifier_shade_walk_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return funcs
end

function modifier_shade_walk_slow:CheckState()
	local state = {}
	if self:GetParent():HasModifier("modifier_penumbra") then
		state = { [MODIFIER_STATE_PASSIVES_DISABLED] = true}
	else
		state = { [MODIFIER_STATE_PASSIVES_DISABLED] = false}
	end
	
	return state
end

function modifier_shade_walk_slow:GetEffectName()
	return "particles/items2_fx/smoke_of_deceit_buff.vpcf"
end

function modifier_shade_walk_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self:GetSpecialValueFor("slow")
end


function modifier_shade_walk_slow:GetModifierMiss_Percentage(params)
	local percent = 0
	if self:GetParent():HasModifier("modifier_penumbra") then
		percent = 100
	else
		percent = 0
	end
	return percent
end

function modifier_shade_walk_slow:IsDebuff()
	return true
end
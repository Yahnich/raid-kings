buccaneer_maelstrom = class({})
LinkLuaModifier( "modifier_torrent", "heroes/buccaneer/buccaneer_maelstrom.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_torrent_slow", "heroes/buccaneer/buccaneer_maelstrom.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function buccaneer_maelstrom:OnSpellStart()
	local caster = self:GetCaster()
	local castPoint = self:GetCursorPosition()

	EmitSoundOnLocationWithCaster(castPoint, "Ability.pre.Torrent", caster)

	CreateModifierThinker(caster, self, "modifier_torrent", {Duration = self:GetSpecialValueFor("torrent_delay")}, castPoint, caster:GetTeam(), false)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_torrent = class({})

function modifier_torrent:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_torrent:OnIntervalThink()
	local units = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("torrent_radius"), {})
	for _,unit in pairs(units) do
		local distance = CalculateDistance(self:GetParent():GetAbsOrigin(), unit:GetAbsOrigin())
		local direction = CalculateDirection(self:GetParent():GetAbsOrigin(), unit:GetAbsOrigin())
		if distance > 5 then
			unit:SetAbsOrigin(unit:GetAbsOrigin()+direction*5)
		else
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end
	end
end

function modifier_torrent:OnRemoved()
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nfx)

		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Ability.Torrent", self:GetCaster())

		local units = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("torrent_radius"), {})
		for _,unit in pairs(units) do
			local knockbackModifierTable = {
				should_stun = 1,
				knockback_duration = 1.53,
				duration = self:GetSpecialValueFor("stun_duration"),
				knockback_distance = 0,
				knockback_height = 200,
				center_x = unit:GetAbsOrigin().x,
				center_y = unit:GetAbsOrigin().y,
				center_z = unit:GetAbsOrigin().z
			}
			self:GetAbility():DealDamage(self:GetCaster(), unit, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockbackModifierTable )
			unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_torrent_slow", {Duration=self:GetSpecialValueFor("slow_duration")+self:GetSpecialValueFor("stun_duration")})
			if unit:HasModifier("modifier_buccaneer_jolly_roger") then
				CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_torrent", {Duration = self:GetSpecialValueFor("torrent_delay")}, unit:GetAbsOrigin(), self:GetCaster():GetTeam(), false)
				unit:RemoveModifierByName("modifier_buccaneer_jolly_roger")
			end
		end
	end
end

function modifier_torrent:GetEffectName()
	return "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf"
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_torrent_slow = class({})

function modifier_torrent_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_torrent_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("slow")
end

function modifier_torrent_slow:IsDebuff()
	return true
end

function modifier_torrent_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_rum.vpcf"
end

function modifier_torrent_slow:StatusEffectPriority()
	return 10
end

function modifier_torrent_slow:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end
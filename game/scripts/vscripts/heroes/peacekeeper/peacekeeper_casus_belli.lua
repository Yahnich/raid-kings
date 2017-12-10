peacekeeper_casus_belli = class({})
LinkLuaModifier( "modifier_casus_belli", "heroes/peacekeeper/peacekeeper_casus_belli.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_casus_belli:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local barrier = self:GetSpecialValueFor("barrier")

	caster:AddNewModifier(caster, self, "modifier_casus_belli", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_generic_barrier", {duration = duration, barrier = barrier})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_casus_belli = class({})

function modifier_casus_belli:OnCreated(table)
	self.caster = self:GetCaster()

	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(self.nfx, 1, self.caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
	
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_casus_belli:OnRemoved()
	ParticleManager:DestroyParticle(self.nfx, false)
end

function modifier_casus_belli:OnIntervalThink()
	if not self.caster:HasModifier("modifier_generic_barrier") then
		self.caster:RemoveModifierByName("modifier_casus_belli")
	end
end

function modifier_casus_belli:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_casus_belli:OnAttack( params )
	if IsServer() then
		if params.target:GetTeam() ~= self.caster:GetTeam() and params.attacker == self.caster then
 			self:GetAbility():DealDamage(self.caster, params.target, self.caster:GetAttackDamage(), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
end
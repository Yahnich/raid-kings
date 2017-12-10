peacekeeper_indictment = class({})
LinkLuaModifier( "modifier_dazed_generic", "libraries/modifiers/modifier_dazed_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_indictment:OnSpellStart()
	local caster = self:GetCaster()
	local cursorTar = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")

	local launch = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_psi_blade.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(launch, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(launch, 1, cursorTar, PATTACH_POINT, "attach_hitloc", cursorTar:GetAbsOrigin(), true)

	if cursorTar:GetTeam() ~= caster:GetTeam() and not cursorTar:IsMagicImmune() then
		cursorTar:AddNewModifier(caster,self,"modifier_dazed_generic",{Duration = duration})
		EmitSoundOn("Hero_TemplarAssassin.Meld",cursorTar)
	end
end
peacekeeper_mens_rea = class({})
LinkLuaModifier( "modifier_mens_rae", "heroes/peacekeeper/peacekeeper_mens_rea.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mens_rae_effect", "heroes/peacekeeper/peacekeeper_mens_rea.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_mens_rea:OnSpellStart()
	local caster = self:GetCaster()
	local cursorTar = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")

	local launch = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_psi_blade.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(launch, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(launch, 1, cursorTar, PATTACH_POINT, "attach_hitloc", cursorTar:GetAbsOrigin(), true)

	if cursorTar:GetTeam() ~= caster:GetTeam() and not cursorTar:IsMagicImmune() then
		local units = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
		for _,unit in pairs(units) do
			unit:RemoveModifierByName("modifier_mens_rae")
		end
		cursorTar:AddNewModifier(caster,self,"modifier_mens_rae",{Duration = duration})
		EmitSoundOn("Hero_TemplarAssassin.Meld",cursorTar)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_mens_rae = class({})

function modifier_mens_rae:OnCreated(table)
	self.caster = self:GetCaster()
	self.mainBaddie = self:GetParent()

	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_mens_rae:GetEffectName()
	return "particles/heroes/peacekeeper/peacekeeper_mens_rae_debuff.vpcf"
end

function modifier_mens_rae:OnIntervalThink()
	if IsServer() then
		local units = self.caster:FindFriendlyUnitsInRadius(self.mainBaddie:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
		for _,unit in pairs(units) do
			unit:AddNewModifier(self.mainBaddie,self:GetAbility(),"modifier_mens_rae_effect",{})
		end
	end
end

function modifier_mens_rae:OnDestroy()
	if IsServer() then
		local units = FindUnitsInRadius(self.caster:GetTeam(),self.mainBaddie:GetAbsOrigin(),nil,FIND_UNITS_EVERYWHERE,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		for _,unit in pairs(units) do
			if unit:HasModifier("modifier_mens_rae_effect") then
				unit:RemoveModifierByName("modifier_mens_rae_effect")
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_mens_rae_effect = class({})

function modifier_mens_rae_effect:OnCreated(table)
	if IsServer() then
		self.ogTarget = self:GetCaster()
		self.ally = self:GetParent()

		self.damage_reflect_pct = self:GetSpecialValueFor("damage")/100
	end
end

function modifier_mens_rae_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_mens_rae_effect:OnTakeDamage( params )
	if IsServer() then
		if params.unit == self.ally then
			--for some reason these are varibles inherit to OnTakeDamage
			--local attacker = params.attacker
			local damage = params.damage

			--Ignore damage
			if self.ally:IsAlive() then
				self.ally:Heal(self.ally:GetHealth() + (damage * self.damage_reflect_pct),self.ally)
			end

			local damageTable = {
				victim = self.ogTarget,
				attacker = self.ally,
				damage = damage * self.damage_reflect_pct/100,
				damage_type = DAMAGE_TYPE_PURE,
			}

			ApplyDamage(damageTable)

			self.nFXIndex = ParticleManager:CreateParticle( "particles/heroes/peacekeeper/peacekeeper_mens_rae.vpcf", PATTACH_POINT_FOLLOW, self.ally )
			ParticleManager:SetParticleControlEnt( self.nFXIndex, 0, self.ally, PATTACH_POINT_FOLLOW, "attach_hitloc", self.ally:GetAbsOrigin(), true )
			ParticleManager:SetParticleControlEnt( self.nFXIndex, 1, self.ogTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self.ogTarget:GetAbsOrigin(), true )
			ParticleManager:ReleaseParticleIndex(self.nFXIndex)

		end
	end
end

function modifier_mens_rae_effect:IsDebuff()
	return false
end
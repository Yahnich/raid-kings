revenant_devouring_shadow = class({})
LinkLuaModifier( "modifier_devouring_shadow_stacks_counter", "heroes/revenant/revenant_devouring_shadow.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_devouring_shadow_stacks", "heroes/revenant/revenant_devouring_shadow.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_devouring_shadow", "heroes/revenant/revenant_devouring_shadow.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_penumbra", "heroes/revenant/revenant_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function revenant_devouring_shadow:GetIntrinsicModifierName()
	if self:IsTrained() then
		return "modifier_devouring_shadow_stacks_counter"
	end
end

function revenant_devouring_shadow:OnUpgrade()
	if self:GetLevel() < 2 then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_devouring_shadow_stacks", {}):SetStackCount(self:GetSpecialValueFor("max_charge"))
	end
end

function revenant_devouring_shadow:OnSpellStart()
	local caster = self:GetCaster()
	local abiltarget = self:GetCursorTarget()
	local direction = CalculateDirection(abiltarget, caster)

	local speed = 750
	local radius = 50
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local stun = self:GetSpecialValueFor("stun")

	local projectileLife = 30

	local vVelocity = direction * speed * FrameTime()

	if caster:FindModifierByName("modifier_devouring_shadow_stacks") and caster:FindModifierByName("modifier_devouring_shadow_stacks"):GetStackCount() > 0 then 
		EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Cast", caster)

		if not abiltarget:IsMagicImmune() and not abiltarget:IsInvisible() then
			local stackCount = caster:FindModifierByName("modifier_devouring_shadow_stacks"):GetStackCount()
			caster:RemoveModifierByName("modifier_devouring_shadow_stacks")

			local ProjectileThink = function(self)
					local position = self:GetPosition()
					local velocity = self:GetVelocity()
					local speed = self:GetSpeed()
					if not abiltarget:IsNull() then
						velocity = CalculateDirection(abiltarget, position) * speed * FrameTime()
						if velocity:Length2D() ~= speed then velocity = velocity:Normalized() * speed end

						self:SetVelocity(velocity)
						self:SetPosition( GetGroundPosition(position, nil) + Vector(0,0,128) + velocity*FrameTime() )
					else
						self:Remove()
					end
				end	--projectileThink
		
			local ProjectileHit = function(self, target, position)
				if not target then return false end
				local caster = self:GetCaster()
				local ability = self:GetAbility()
				if target:IsAlive() and not target:IsMagicImmune() and target == abiltarget and target:GetTeam() ~= caster:GetTeam() then
					if not self.hitUnits[target:entindex()] then
						local damage = self:GetAbility():DealDamage(caster, target, damage*stackCount, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
						target:AddNewModifier(caster, ability, "modifier_devouring_shadow", {Duration=duration, damage=damage})
						if target:HasModifier("modifier_penumbra") then
							target:RemoveModifierByName("modifier_penumbra")
							target:AddNewModifier(caster, ability, "modifier_stunned_generic", {Duration=stun})
						end
						self.hitUnits[target:entindex()] = true
					end
					return false
				else
					return true
				end
			end --projectilehit
		
		ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/heroes/revenant/revenant_devouring_shadow.vpcf",
																			  position = caster:GetAbsOrigin(),
																			  caster = caster,
																			  ability = self,
																			  speed = speed,
																			  radius = radius,
																			  velocity = vVelocity,
																			  duration = projectileLife,
																			  hitUnits = {}})
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_devouring_shadow_stacks_counter = class({})

function modifier_devouring_shadow_stacks_counter:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
	end
end

function modifier_devouring_shadow_stacks_counter:OnIntervalThink()
	if IsServer() then
		if not self:GetCaster():FindModifierByName("modifier_devouring_shadow_stacks") or self:GetCaster():FindModifierByName("modifier_devouring_shadow_stacks"):GetStackCount() < 3 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_devouring_shadow_stacks", {}):IncrementStackCount()
		end
	end
end

function modifier_devouring_shadow_stacks_counter:IsHidden()
	return true 
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_devouring_shadow_stacks = class({})
function modifier_devouring_shadow_stacks:IsDebuff()
	return false
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_devouring_shadow = class({})

function modifier_devouring_shadow:OnCreated(table)
	if IsServer() then
		self.damage = table.damage or 0
		self:StartIntervalThink(1.0)
	end
end

function modifier_devouring_shadow:OnIntervalThink()
	if IsServer() then
		self:GetCaster():Lifesteal(self:GetAbility(), 100, self.damage/self:GetDuration(), self:GetParent(), DAMAGE_TYPE_MAGICAL, DOTA_LIFESTEAL_SOURCE_ABILITY)
	end
end

function modifier_devouring_shadow:GetEffectName()
	return "particles/items2_fx/veil_of_discord_debuff.vpcf"
end

function modifier_devouring_shadow:IsDebuff()
	return true
end
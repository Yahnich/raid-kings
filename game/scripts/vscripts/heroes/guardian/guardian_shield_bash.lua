guardian_shield_bash = class({})
LinkLuaModifier( "modifier_shield_bash", "heroes/guardian/guardian_shield_bash.lua", LUA_MODIFIER_MOTION_NONE )

function guardian_shield_bash:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster:GetAbsOrigin()) * Vector(1,1,0)

	local distance = self:GetSpecialValueFor("knockback")
	local damage = self:GetSpecialValueFor("damage")
	local speed = 1000

	EmitSoundOn("Hero_Sven.StormBolt", caster)

	local ProjectileHit = function(self, target, position)
		if not target then return end
		if target ~= nil and ( not target:IsMagicImmune() ) and ( not target:IsInvulnerable() ) and target:GetTeam() ~= caster:GetTeam() then
			if not self.hitUnits[target:entindex()] then
				self:GetAbility():DealDamage(caster, target, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				
				--EmitSoundOn("Hero_DragonKnight.DragonTail.Target", target)
				EmitSoundOn("Hero_Sven.StormBoltImpact", target)
				local originPoint = target:GetAbsOrigin()
				local directionVector = CalculateDirection(position, originPoint) -- Original vectors
				local rotateVector = Vector(directionVector.y, -directionVector.x, 0) -- Normal vector
				local compareVector = target:GetAbsOrigin() - originPoint -- Comparative vector
				local sideResult = rotateVector:Dot(compareVector)
				local pushDir = (target:GetAbsOrigin() - position)
				local distanceCap = (distance - directionVector:Length2D()) / distance
				if (target:GetAbsOrigin() - position):Length2D() > 200 or sideResult ~= 0 then
					if sideResult > 0 then
						pushDir = Vector(directionVector.y, -directionVector.x, 0)
					else
						pushDir = Vector(-directionVector.y, directionVector.x, 0)
					end
				else
					distanceCap = distanceCap * 1.5
				end
				pushDir = pushDir:Normalized()
				
				target:AddNewModifier(caster, self:GetAbility(), "modifier_shield_bash", {pushMod = distanceCap, pushDirx = pushDir.x, pushDiry = pushDir.y})
				self.hitUnits[target:entindex()] = true
			end
		end
		return true
	end--projectilehit

	ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = "particles/heroes/guardian/guardian_shield_smash_projectile.vpcf",
																  position = caster:GetAbsOrigin(),
																  caster = caster,
																  ability = self,
																  speed = speed,
																  radius = self:GetSpecialValueFor("radius"),
																  velocity = direction * speed,
																  duration = 10,
																  distance = distance,
																  hitUnits = {}})
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
modifier_shield_bash = modifier_shield_bash or class({})

function modifier_shield_bash:OnCreated(kv)
	if IsServer() then
		self.parent = self:GetParent()
		EmitSoundOn("Hero_Tiny.Toss.Target", self:GetParent())
		self.max_distance = self:GetAbility():GetSpecialValueFor("knockback")/2
		self.distance_to_travel = self.max_distance * kv.pushMod
		self.pushDir = Vector(tonumber(kv.pushDirx), tonumber(kv.pushDiry), 0)
		if self.distance_to_travel < self.max_distance then self.distance_to_travel = self.max_distance end
		self.distance = 0
		self.speed = 950
		if self.parent:HasMovementCapability() then
			self:StartMotionController()
		end
	end
end

function modifier_shield_bash:OnRefresh(kv)
	if IsServer() then
		EmitSoundOn("Hero_Tiny.Toss.Target", self:GetParent())
		self.max_distance = self:GetAbility():GetSpecialValueFor("knockback")/2
		self.distance_to_travel = self.max_distance * kv.pushMod
		self.pushDir = Vector(tonumber(kv.pushDirx), tonumber(kv.pushDiry), 0)
		if self.distance_to_travel < self.max_distance then self.distance_to_travel = self.max_distance end
		self.distance = 0
		self.speed = 950
	end
end

function modifier_shield_bash:OnDestroy()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned_generic", {duration=self:GetAbility():GetSpecialValueFor("stun_duration")})
	end
end

function modifier_shield_bash:DoControlledMotion()
	local parent = self.parent
	if self.distance < self.distance_to_travel and self:GetParent():IsAlive() and not self:GetParent():IsNull() then
		parent:SetAbsOrigin(parent:GetAbsOrigin() + self.pushDir * self.speed*FrameTime())
		self.distance = self.distance + self.speed*FrameTime()
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:Destroy()
		return nil
	end       
end

function modifier_shield_bash:IsHidden()
	return true
end

function modifier_shield_bash:GetEffectName()
	return "particles/econ/items/windrunner/windrunner_cape_sparrowhawk/windrunner_windrun_sparrowhawk.vpcf"
end

function modifier_shield_bash:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_shield_bash:IsPurgable()
	return false
end
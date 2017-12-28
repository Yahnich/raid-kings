EHP_PER_ARMOR = 0.05
DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

function Context_Wrap(o, funcname)
	return function(...) o[funcname](o, ...) end
end

function HasValInTable(checkTable, val)
	for key, value in pairs(checkTable) do
		if value == val then return true end
	end
	return false
end

function MergeTables( t1, t2 )		
	for name,info in pairs(t2) do		
		if type(info) == "table"  and type(t1[name]) == "table" then		
 			MergeTables(t1[name], info)		
 		else		
 			t1[name] = info		
 		end		
	end		
end		
 		
function PrintAll(t)		
	for k,v in pairs(t) do		
		print(k,v)		
	end		
end		
		
function table.removekey(t1, key)		
    for k,v in pairs(t1) do		
		if k == key then		
			table.remove(t1,k)		
		end		
	end		
end		
		
function table.removeval(t1, val)		
    for k,v in pairs(t1) do		
		if t1[k] == val then		
			table.remove(t1,k)		
		end		
	end		
end

function GetPerpendicularVector(vector)
	return Vector(vector.y, -vector.x)
end

function ActualRandomVector(maxLength, flMinLength)
	local minLength = flMinLength or 0
	return RandomVector(RandomInt(minLength, maxLength))
end

function HasBit(checker, value)
	return bit.band(checker, value) == value
end

function toboolean(thing)
	if type(thing) == "number" then
		if thing == 1 then return true
		elseif thing == 0 then return false
		else error("number type not 1 or 0") end
	elseif type(thing) == "string" then
		if thing == "true" or thing == "1" then return true
		elseif thing == "false" or thing == "0" then return false
		else error("string type not true or false") end
	end
end

function CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	return direction
end

function CDOTA_BaseNPC:CreateDummy(position)
	local dummy = CreateUnitByName("npc_dummy_unit", position, false, nil, nil, self:GetTeam())
	dummy:AddAbility("hide_hero"):SetLevel(1)
	return dummy
end

function CDOTA_BaseNPC_Hero:CreateSummon(unitName, position, duration)
	local summon = CreateUnitByName(unitName, position, true, self, nil, self:GetTeam())
	summon:SetControllableByPlayer(self:GetPlayerID(), true)
	self.summonTable = self.summonTable or {}
	table.insert(self.summonTable, summon)
	summon:SetOwner(self)
	summon:AddNewModifier(self, nil, "modifier_summon_handler", {duration = duration})
	if duration and duration > 0 then
		summon:AddNewModifier(self, nil, "modifier_kill", {duration = duration})
	end
	StartAnimation(summon, {activity = ACT_DOTA_SPAWN, rate = 1.5, duration = 2})
	return summon
end

function CDOTA_BaseNPC_Hero:RemoveSummon(entity)
	for id,ent in pairs(self.summonTable) do
		if ent == entity then
			table.remove(self.summonTable, id)
		end
	end
end

function CDOTA_BaseNPC:IsBeingAttacked()
	local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, 999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	for _, enemy in pairs(enemies) do
		if enemy:IsAttackingEntity(self) then return true end
	end
	return false
end

function CDOTA_BaseNPC:PerformAbilityAttack(target, bProcs, ability)
	self.autoAttackFromAbilityState = {} -- basically the same as setting it to true
	self.autoAttackFromAbilityState.ability = ability
	self:PerformAttack(target,bProcs,bProcs,true,false,false,false,true)
	Timers:CreateTimer(function() self.autoAttackFromAbilityState = nil end)
end

function CDOTA_BaseNPC:PerformGenericAttack(target, immediate)
	self:PerformAttack(target, true, true, true, false, not immediate or false, false, false)
end

function CDOTA_Modifier_Lua:AttachEffect(pID)
	self:AddParticle(pID, false, false, 0, false, false)
end

function CDOTA_Modifier_Lua:GetSpecialValueFor(specVal)
	return self:GetAbility():GetSpecialValueFor(specVal)
end

function CDOTABaseAbility:DealDamage(attacker, victim, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	local damageType = DAMAGE_TYPE_MAGICAL or data.damage_type 
	local damageFlags = DOTA_DAMAGE_FLAG_NONE or data.damage_flags
	local localdamage = damage
	local spellText = spellText or 0
	local ability = self or data.ability 
	if spellText > 0 then
		local damage = ApplyDamage({victim = victim, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,victim,damage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
		return damage
	else
		return ApplyDamage({victim = victim, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	end
end

function CDOTABaseAbility:DealAOEDamage(attacker, damage, position, radius, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	local damageType = DAMAGE_TYPE_MAGICAL or data.damage_type 
	local damageFlags = DOTA_DAMAGE_FLAG_NONE or data.damage_flags
	local localdamage = damage
	local team = attacker:GetTeamNumber()
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY or data.iTeam
	local iType = DOTA_UNIT_TARGET_ALL or data.iType
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE or data.iFlag
	local iOrder = FIND_ANY_ORDER or data.iOrder
	local spellText = spellText or 0
	local ability = self or data.ability
	if spellText > 0 then
		local AOETargets = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
		for _, target in pairs(AOETargets) do
			local damage = ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
			SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,target,damage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
			return damage
		end
	else
		local AOETargets = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
		for _, target in pairs(AOETargets) do
			local damage = ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
			return damage
		end
	end
end

function CDOTABaseAbility:DealMaxHPAOEDamage(attacker, damage_pct, position, radius, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	local damageType = DAMAGE_TYPE_MAGICAL or data.damage_type 
	local damageFlags = DOTA_DAMAGE_FLAG_NONE or data.damage_flags
	local team = attacker:GetTeamNumber()
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY or data.iTeam
	local iType = DOTA_UNIT_TARGET_ALL or data.iType
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE or data.iFlag
	local iOrder = FIND_ANY_ORDER or data.iOrder
	local spellText = spellText or 0
	local ability = self or data.ability
	if spellText > 0 then
		local AOETargets = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
		for _, target in pairs(AOETargets) do
			local damage = ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = target:GetMaxHealth() * damage_pct / 100, damage_flags = damageFlags})
			SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,target,damage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
			return damage
		end
	else
		local AOETargets = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
		for _, target in pairs(AOETargets) do
			local damage = ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = target:GetMaxHealth() * damage_pct / 100, damage_flags = damageFlags})
			return damage
		end
	end
end


function FindUnitsInCone(teamNumber, vDirection, vPosition, flSideRadius, flLength, hCacheUnit, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
	local enemies = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, flSideRadius + flLength, targetTeam, targetUnit, targetFlags, findOrder, bCache )
	local unitTable = {}
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			if enemy ~= nil then
				local vToPotentialTarget = enemy:GetOrigin() - vPosition
				local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
				local flLengthAmount = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )
				if ( flSideAmount < flSideRadius ) and ( flLengthAmount > 0.0 ) and ( flLengthAmount < flLength ) then
					table.insert(unitTable, enemy)
				end
			end
		end
	end
	return unitTable
end

-- New taunt mechanics
function CDOTA_BaseNPC:GetTauntTarget()
	local target = nil
	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetTauntTarget and not target then 
			target = modifier:GetTauntTarget()
		elseif modifier.GetTauntTarget and target and CalculateDistance(target, self) < CalculateDistance(modifier:GetTauntTarget(), self) then 
			target = modifier:GetTauntTarget()
		end
	end
	return target
end

-- function PrecacheAbility(abName)
	-- if GameRules.AbilityKV[abName] and GameRules.AbilityKV[abName]["precache"] then
		-- for resourceType, resourcePath in pairs( GameRules.AbilityKV[abName]["precache"] ) do
			-- PrecacheResource(resourceType, resourcePath, GameRules.PrecacheContext)
		-- end
	-- end
-- end

 function CDOTA_BaseNPC:AddAbilityPrecache(abName)
	-- PrecacheAbility(abName)
 	return self:AddAbility(abName)
 end

function CDOTA_BaseNPC:HasTalent(talentName)
	if self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

function FindAllEntitiesByClassname(name)
	local entList = {}
	local sortList = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 99999, 3, 63, DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, -1, false)
	for _, unit in pairs(sortList) do
		if unit:GetClassname() == name then
			table.insert(entList, unit)
		end
	end
	return entList
end

function GetTableLength(rndTable)
	local counter = 0
	for k,v in pairs(rndTable) do
		counter = counter + 1
	end
	return counter
end

function CDOTA_BaseNPC:FindTalentValue(talentName, value)
	if self:HasAbility(talentName) then
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value or "value")
	end
	return 0
end

function CDOTA_BaseNPC:GetAverageBaseDamage()
	return (self:GetBaseDamageMax() + self:GetBaseDamageMin())/2
end

function CDOTA_BaseNPC:SetAverageBaseDamage(average, variance) -- variance is in percent (50 not 0.5)
	local var = variance or 0
	self:SetBaseDamageMax(average*(1+(var/100)))
	self:SetBaseDamageMin(average*(1+(var/100)))
end

function CDOTABaseAbility:Refresh()
	if not self:IsActivated() then
		self:SetActivated(true)
	end
	if self.delayedCooldownTimer then self:EndDelayedCooldown() end
    self:EndCooldown()
end

function CDOTABaseAbility:GetTrueCastRange()
	local castrange = self:GetCastRange()
	return castrange
end

function CDOTA_Ability_Lua:GetTrueCastRange()
	local castrange = self:GetCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster())
	return castrange
end

function CDOTA_BaseNPC:KillTarget()
	if not ( self:IsInvulnerable() or self:IsOutOfGame() or self:IsUnselectable() or self:NoHealthBar() ) then
		self:ForceKill(true)
	end
end

function CDOTA_BaseNPC:GetBaseProjectileModel()
	if self:IsRangedAttacker() then
		return GameRules.UnitKV[self:GetUnitName()]["ProjectileModel"] or nil
	else
		return nil
	end
end

function CDOTA_BaseNPC:GetProjectileModel()
	if self:IsRangedAttacker() then
		return self.currentProjectileModel or self:GetBaseProjectileModel()
	else
		return nil
	end
end

function CDOTA_BaseNPC:SetProjectileModel(projectile)
	self:SetRangedProjectileName(projectile)
	self.previousProjectileModel = self.currentProjectileModel or self:GetBaseProjectileModel()
	self.currentProjectileModel = projectile
end

function CDOTA_BaseNPC:RevertProjectile()
	self:SetRangedProjectileName(self.previousProjectileModel)
	local newModel = self.previousProjectileModel
	self.previousProjectileModel = self.currentProjectileModel
	self.currentProjectileModel = newModel
end


function CDOTA_BaseNPC:GetAngleDifference(hEntity)
	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local victim_angle = hEntity:GetAnglesAsVector().y
	local origin_difference = hEntity:GetAbsOrigin() - self:GetAbsOrigin()

	-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Convert the radian to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	attacker_angle = attacker_angle + 180.0
	
	-- Finally, get the angle at which the victim is facing Riki.
	local result_angle = (attacker_angle - victim_angle)
	result_angle = math.abs(result_angle)
	return result_angle
end

function CDOTA_BaseNPC:IsAtAngleWithEntity(hEntity, flDesiredAngle)
	local angleDiff = self:GetAngleDifference(hEntity)
	if angleDiff >= (180 - flDesiredAngle / 2) and angleDiff <= (180 + flDesiredAngle / 2) then 
		return true
	else
		return false
	end
end
	

function CDOTA_BaseNPC:Refresh(bItems)
    for i = 0, self:GetAbilityCount() - 1 do
        local ability = self:GetAbilityByIndex( i )
        if ability then
			ability:Refresh()
        end
    end
	if bItems then
		for i=0, 5, 1 do
			local current_item = self:GetItemInSlot(i)
			if current_item ~= nil and current_item ~= item then
				current_item:Refresh()
			end
		end
	end
end


function  CDOTA_BaseNPC:ConjureImage( position, duration, outgoing, incoming, specIllusionModifier )
	local player = self:GetPlayerID()

	local unit_name = self:GetUnitName()
	local origin = position or self:GetAbsOrigin() + RandomVector(100)
	local outgoingDamage = outgoing
	local incomingDamage = incoming

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, self, nil, self:GetTeamNumber())
	illusion:SetPlayerID(self:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)
		
	-- Level Up the unit to the casters level
	local casterLevel = self:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local abilityillu = self:GetAbilityByIndex(abilitySlot)
		if abilityillu ~= nil then 
			local abilityLevel = abilityillu:GetLevel()
			local abilityName = abilityillu:GetAbilityName()
			if illusion:FindAbilityByName(abilityName) ~= nil and abilityName ~= "phantom_lancer_juxtapose" then
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			end
		end
	end

			-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = self:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	if specIllusionModifier then
		illusion:AddNewModifier(self, ability, specIllusionModifier, { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	end
	illusion:AddNewModifier(self, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
			
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()
end

function CDOTABaseAbility:IsInnateAbility()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["InnateAbility"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:HasPureCooldown()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["HasPureCooldown"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTA_BaseNPC:IsSlowed()
	return self:GetIdealSpeed() < self:GetIdealSpeedNoSlows()
end

function CDOTA_BaseNPC:IsDisabled()
	return self:IsSlowed() or self:IsStunned() or self:IsRooted() or self:IsSilenced() or self:IsHexed() or self:IsDisarmed()
end

function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (EHP_PER_ARMOR * armornpc) / (1 + (EHP_PER_ARMOR * math.abs(armornpc)))
	armor_reduction = 100 - (armor_reduction * 100)
	return armor_reduction
end

function CDOTA_BaseNPC:FindItemByName(sItemname, bBackpack)
	local inventoryIndex = 5
	if bBackpack then inventoryIndex = 8 end
	for i = 0, inventoryIndex do
		local item = self:GetItemInSlot(i)
		if item and item:GetName() == sItemname then 
			return item
		end
	end
end

function CDOTA_BaseNPC:ShowPopup( data )
    if not data then return end

    local target = self
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or false
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player then
		local playerent = PlayerResource:GetPlayer( self:GetPlayerID() )
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, playerent)
    end
	
	if number then
		number = math.floor(number+0.5)
	end

    local digits = 0
    if number ~= nil then digits = string.len(number) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end

function CDOTA_BaseNPC:FindModifiersByAbility(abilityname)
	local modifiers = self:FindAllModifiers()
	local returnTable = {}
	for _,modifier in pairs(modifiers) do
		if modifier:GetAbility():GetName() == abilityname then
			table.insert(returnTable, modifier)
		end
	end
	return returnTable
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = self:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then 
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

function CDOTA_Modifier_Lua:GetTalentSpecialValueFor(value)
	local base = self:GetAbility():GetSpecialValueFor(value)
	local talentName
	local kv = self:GetAbility():GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then 
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

function CDOTABaseAbility:StartDelayedCooldown(flDelay)
	if self.delayedCooldownTimer then
		self:EndDelayedCooldown()
	end
	self:EndCooldown()
	self:UseResources(false, false, true)
	local cd = self:GetCooldownTimeRemaining()
	local ability = self
	self.delayedCooldownTimer = Timers:CreateTimer(0, function()
		ability:EndCooldown()
		ability:StartCooldown(cd)
		return 0
	end)
	if flDelay then
		Timers:CreateTimer(flDelay, function() ability:EndDelayedCooldown() end)
	end
end

function CDOTABaseAbility:EndDelayedCooldown()
	if self.delayedCooldownTimer then
		Timers:RemoveTimer(self.delayedCooldownTimer)
		self.delayedCooldownTimer = nil
	end
end

function CDOTABaseAbility:ModifyCooldown(amt)
	local currCD = self:GetCooldownTimeRemaining()
	self:EndCooldown()
	self:StartCooldown(currCD + amt)
end

function RotateVector2D(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function ToRadians(degrees)
	return degrees * math.pi / 180
end

function ToDegrees(radians)
	return radians * 180 / math.pi 
end

function CDOTA_BaseNPC:IsSameTeam(unit)
	return (self:GetTeamNumber() == unit:GetTeamNumber())
end

function CDOTA_BaseNPC:AddBarrier(amount, caster, ability, duration)
	self:AddNewModifier(caster, ability, "modifier_generic_barrier", {duration = duration, barrier = amount})
end

function CDOTA_BaseNPC:Lifesteal(source, lifestealPct, damage, target, damage_type, iSource)
	local damageDealt = damage or 0
	local sourceType = iSource or 0
	if sourceType == DOTA_LIFESTEAL_SOURCE_ABILITY then
		local oldHP = target:GetHealth()
		ApplyDamage({victim = target, attacker = self, damage = damage, damage_type = damage_type, ability = source})
		damageDealt = math.abs(oldHP - target:GetHealth())
	elseif sourceType == DOTA_LIFESTEAL_SOURCE_ATTACK then
		local oldHP = target:GetHealth()
		self:PerformAttack(target, true, true, true, true, false, false, false)
		damageDealt = math.abs(oldHP - target:GetHealth())
	end
	local flHeal = damageDealt * lifestealPct / 100
	self:HealEvent(flHeal, source, self)
	local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		ParticleManager:SetParticleControlEnt(lifesteal, 0, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(lifesteal, 1, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(lifesteal)
end

function CDOTA_BaseNPC:HealEvent(amount, sourceAb, healer) -- for future shit
	local healBonus = 1
	local flAmount = amount
	if healer then
		for _,modifier in ipairs( healer:FindAllModifiers() ) do
			if modifier.GetOnHealBonus then
				healBonus = healBonus + ((modifier:GetOnHealBonus() or 0)/100)
			end
		end
	end
	
	flAmount = flAmount * healBonus
	local params = {amount = flAmount, source = sourceAb, unit = healer, target = self}
	local units = self:FindAllUnitsInRadius(self:GetAbsOrigin(), -1)
	
	for _, unit in ipairs(units) do
		if unit.FindAllModifiers then
			for _, modifier in ipairs( unit:FindAllModifiers() ) do
				if modifier.OnHealed then
					modifier:OnHealed(params)
				end
				if modifier.OnHeal then
					modifier:OnHeal(params)
				end
				if modifier.OnHealRedirect then
					local reduction = modifier:OnHealRedirect(params) or 0
					flAmount = flAmount + reduction
				end
			end
		end
	end
	SendOverheadEventMessage(self, OVERHEAD_ALERT_HEAL, self, flAmount, healer)
	self:Heal(flAmount, sourceAb)
	return flAmount
end

function CDOTA_BaseNPC:SwapAbilityIndexes(index, swapname)
	local ability = self:GetAbilityByIndex(index)
	local swapability = self:FindAbilityByName(swapname)
	self:SwapAbilities(ability:GetName(), swapname, false, true)
	swapability:SetAbilityIndex(index)
end

function CDOTA_BaseNPC:ApplyLinearKnockback(distance, strength, source)
	local direction = (self:GetAbsOrigin() - source:GetAbsOrigin()):Normalized()
	self.isInKnockbackState = true
	local distance_traveled = 0
	local distAdded = (distance/0.2)*FrameTime() * strength
	StartAnimation(self, {activity = ACT_DOTA_FLAIL, rate = 1, duration = distAdded/distance})
	Timers:CreateTimer(function ()
		if not self:GetParent():HasMovementCapability() then return end
		if distance_traveled < distance and self:IsAlive() and not self:IsNull() then
			self:SetAbsOrigin(self:GetAbsOrigin() + direction * distAdded)
			distance_traveled = distance_traveled + distAdded
			return FrameTime()
		else
			FindClearSpaceForUnit(self, self:GetAbsOrigin(), true)
			self.isInKnockbackState = false
			return nil
		end 
	end)
end

function CDOTA_BaseNPC:IsKnockedBack()
	return self.isInKnockbackState
end


function FindAllUnits(data)
	local team = DOTA_TEAM_GOODGUYS
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, Vector(0,0), nil, -1, iTeam, iType, iFlag, iOrder, false)
end

function CDOTA_BaseNPC:FindEnemyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindFriendlyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindAllUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end


function CDOTA_BaseNPC:FindEnemyUnitsInRing(position, maxRadius, minRadius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	
		local innerRing = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
		local outerRing = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
		
		local resultTable = {}
		for _, unit in ipairs(outerRing) do
			local addToTable = true
			for _, exclude in ipairs(innerRing) do
				if unit == exclude then
					addToTable = false
					break
				end
			end
			if addToTable then
				table.insert(resultTable, unit)
			end
		end
		return resultTable
		
	else return {} end
end

function CDOTA_BaseNPC:FindEnemyUnitsInRadius(position, radius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
		return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
	else return {} end
end

function CDOTA_BaseNPC:FindFriendlyUnitsInRadius(position, radius, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function CDOTA_BaseNPC:FindAllUnitsInRadius(position, radius, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function ParticleManager:FireWarningParticle(position, radius)
	local thinker = ParticleManager:CreateParticle("particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(thinker, 0, position)
			ParticleManager:SetParticleControl(thinker, 2, Vector(6,0,1))
			ParticleManager:SetParticleControl(thinker, 1, Vector(radius,0,0))
			ParticleManager:SetParticleControl(thinker, 3, Vector(255,0,0))
			ParticleManager:SetParticleControl(thinker, 4, Vector(0,0,0))
	ParticleManager:ReleaseParticleIndex(thinker)
end

function ParticleManager:FireLinearWarningParticle(startPos, endPos)
	local fx = ParticleManager:FireParticle("particles/generic_linear_indicator.vpcf", PATTACH_WORLDORIGIN, nil, { [0] = startPos,
																													[1] = endPos} )																						
end

function ParticleManager:FireTargetWarningParticle(target)
	local fx = ParticleManager:FireParticle("particles/generic/generic_marker.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
end

function ParticleManager:FireParticle(effect, attach, owner, cps)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)
	if cps then
		for cp, value in pairs(cps) do
			ParticleManager:SetParticleControl(FX, tonumber(cp), value)
		end
	end
	ParticleManager:ReleaseParticleIndex(FX)
end

function ParticleManager:FireRopeParticle(effect, attach, owner, target)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)

	ParticleManager:SetParticleControlEnt(FX, 0, owner, PATTACH_POINT_FOLLOW, "attach_hitloc", owner:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(FX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	ParticleManager:ReleaseParticleIndex(FX)
end

function ParticleManager:ClearParticle(cFX)
	ParticleManager:DestroyParticle(cFX, false)
	ParticleManager:ReleaseParticleIndex(cFX)
end

function CDOTA_Modifier_Lua:StartMotionController()
	if not self:GetParent():IsNull() and not self:IsNull() and self.DoControlledMotion and self:GetParent():HasMovementCapability() then
		self.controlledMotionTimer = Timers:CreateTimer(FrameTime(), function()
			if self:IsNull() or self:GetParent():IsNull() then return end
			self:DoControlledMotion() 
			return FrameTime()
		end)
	else
	end
end

function CDOTA_Modifier_Lua:AddIndependentStack()
	self:IncrementStackCount()
	Timers:CreateTimer(self:GetDuration(), function() if not self:IsNull() then self:DecrementStackCount() end end)
end


function CDOTA_Modifier_Lua:StopMotionController()
	Timers:RemoveTimers(self.controlledMotionTimer)
end

function CDOTA_Modifier_Lua:AddEffect(id)
	self:AddParticle(id, false, false, 0, false, false)
end

function CDOTA_Modifier_Lua:AddStatusEffect(id, priority)
	self:AddParticle(id, false, true, priority, false, false)
end

function CDOTA_Modifier_Lua:AddOverHeadEffect(id)
	self:AddParticle(id, false, false, 0, false, true)
end

function CDOTA_Modifier_Lua:AddHeroEffect(id)
	self:AddParticle(id, false, false, 0, true, false)
end

function CDOTA_BaseNPC:FindRandomEnemyInRadius(position, radius, data)
	for _, unit in ipairs(self:FindEnemyUnitsInRadius(position, radius, data)) do
		return unit
	end
end

function CDOTA_BaseNPC:Dispel(hCaster, bHard)
	local sameTeam = (hCaster:GetTeam() == self:GetTeam())
	self:Purge(not sameTeam, sameTeam, false, bHard, bHard)
end

function CDOTA_BaseNPC:SmoothFindClearSpace(position)
	self:SetAbsOrigin(position)
	ResolveNPCPositions(position, self:GetHullRadius() + self:GetCollisionPadding())
end

function CDOTABaseAbility:Stun(target, duration, bDelay)
	target:AddNewModifier(self:GetCaster(), self, "modifier_stunned_generic", {duration = duration, delay = bDelay})
end

function CDOTA_BaseNPC:AddChill(hAbility, hCaster, chillDuration)
	self:AddNewModifier(hCaster, hAbility, "modifier_chill_generic", {Duration = chillDuration}):IncrementStackCount()
end

function CDOTA_BaseNPC:GetChillCount()
	if self:HasModifier("modifier_chill_generic") then
		return self:FindModifierByName("modifier_chill_generic"):GetStackCount()
	else
		return 0
	end
end

function CDOTA_BaseNPC:SetChillCount( count )
	if self:HasModifier("modifier_chill_generic") then
		self:FindModifierByName("modifier_chill_generic"):SetStackCount(count)
	end
end

function CDOTA_BaseNPC:Freeze(hAbility, hCaster, duration)
	self:AddNewModifier(hCaster, hAbility, "modifier_frozen_generic", {Duration = duration})
end

function CDOTA_BaseNPC:IsChilled()
	if self:HasModifier("modifier_chill_generic"):GetStackCount() > 0 then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsFrozenGeneric()
	if self:HasModifier("modifier_frozen_generic") then
		return true
	else
		return false
	end
end
MAXIMUM_ATTACK_SPEED	= 700
MINIMUM_ATTACK_SPEED	= 20

ROUND_END_DELAY = 3

DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2


CUSTOM_GAME_STATE_HERO_SELECTION = 1
CUSTOM_GAME_STATE_SKILL_SELECTION = 2
CUSTOM_GAME_STATE_GAME = 3
_G["HERO_SELECTION_TIME"] = 80
_G["SKILL_SELECTION_TIME"] = 80

MAP_CENTER = Vector(332, -1545)

if CRaidKings == nil then
	CRaidKings = class({})
end

require( "libraries/Timers" )
require( "libraries/notifications" )
require("libraries/utility")
require("libraries/animations")
require("hero_selection")
require("skill_selection")
require("statsmanager")
require("itemmanager")

-- require("relics/relic")
-- require("relics/relicpool")

-- Precache resources
function Precache( context )
	PrecacheResource( "particle", "particles/generic_dazed_side.vpcf", context )
	PrecacheResource( "particle", "particles/items_fx/courier_shield.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", context )
	PrecacheResource( "particle", "particles/generic_gameplay/generic_slowed_cold.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_frost_armor.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", context )
	
	for hero, activated in pairs( LoadKeyValues("scripts/npc/activelist.txt") ) do
		PrecacheUnitByNameSync(hero, context)
	end
	
	for abName, content in pairs( LoadKeyValues("scripts/npc/npc_abilities_custom.txt") ) do
		if content["precache"] then
			for resourceType, resourcePath in pairs( content["precache"] ) do
				PrecacheResource( resourceType, resourcePath, context )
			end
		end
	end
	
	for model, particleTable in pairs( LoadKeyValues("scripts/keyvalues/cosmetics.kv") ) do
		for particleType, typeTable in pairs(particleTable) do
			for _, particle in pairs(typeTable) do
				PrecacheResource( "particle", particle, context )
			end
		end
	end
end

-- Actually make the game mode when we activate
function Activate()
	GameRules.gameMode = CRaidKings()
	GameRules.gameMode:InitGameMode()
	require("projectilemanager")
	-- require('statsmanager')
end


function CRaidKings:InitGameMode()
	print ("Raid Kings Loaded")
	GameRules.CRaidKings = CRaidKings()
	
	-- Load unit KVs into main kv
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	
	GameRules.HeroList = LoadKeyValues("scripts/npc/activelist.txt")
	
	GameRules.CosmeticsList = LoadKeyValues("scripts/keyvalues/cosmetics.kv")
	print(GetMapName())
	local heroList = {}
	for k,v in pairs(GameRules.HeroList) do
		table.insert(heroList, k)
	end
	CustomNetTables:SetTableValue("hero_selection", "herolist", heroList)
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_DAMAGE, 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP, 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT, 0 )
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_DAMAGE, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ARMOR, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0	 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT, 0 )
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE , 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MANA  , 0 ) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_SPELL_AMP_PERCENT, 0 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT, 0 ) 
	
	
	GameRules:SetHeroSelectionTime( 0.0 )
	GameRules:SetPreGameTime( 0.0 )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetCustomGameSetupAutoLaunchDelay(0) -- fix valve bullshit
	
	local mapInfo = LoadKeyValues( "addoninfo.txt" )[GetMapName()]
	
	GameRules.BasePlayers = mapInfo.MaxPlayers
	GameRules._maxLives =  mapInfo.Lives
	GameRules.gameDifficulty =  mapInfo.Difficulty
	
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )


	GameRules:SetTreeRegrowTime( 30.0 )
	GameRules:SetCreepMinimapIconScale( 1.5 )
	GameRules:SetRuneMinimapIconScale( 1 )
	GameRules:SetGoldTickTime( 600.0 )
	GameRules:SetGoldPerTick( 0 )
	
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetBuybackEnabled( false )
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
	xpTable = {
		0,-- 1
		100,-- 2
		200,-- 3
		300,-- 4
		400,-- 5
		500,-- 6
		600,-- 7
		700,-- 8
		800,-- 9
		900,-- 10
		1000,-- 11
		1200,-- 12
		1400,-- 13
		1600,-- 14
		1800,-- 15
		2000,-- 16
		2250,-- 17
		2500,-- 18
		2750,-- 19
		3000,-- 20
		3500,-- 21
		4000,-- 22
		4500,-- 23
		5000,-- 24
		5500, -- 25
		6000, -- 26
		7000, -- 27
		8000, -- 28
		9000, -- 29
		10000, -- 30
		12500, -- 31
		15000, -- 32
		17500, -- 33
		20000, -- 34
		25000, -- 35
		30000, -- 36
		35000, --37
		40000, --38
		50000, --39
		60000, --40
		70000, --41
		80000, --42
		100000, --43
		150000, --44
		200000, --45
		300000, --46
		400000, --47
		500000, --48
		600000, --49
		700000, --50
		800000, --51
		900000, --52
		1000000, --53
		1200000, --54
		1400000, --55
		1600000, --56
		1800000, --57
		2000000, --58
		2200000, --59
		2400000, --60
		2600000, --61
		2800000, --62
		3000000, --63
		3500000, --64
		4000000, --65
		4500000, --66
		5000000, --67
		5500000, --68
		6000000, --69
		7000000, --70
		8000000, --71
		9000000, --72
		10000000, --73
		12500000, --74
		15000000, --75
		17500000, --76
		20000000, --77
		25000000, --78
		30000000, --79
		40000000, --80
	}

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 80 )
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( xpTable )
	
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed(MINIMUM_ATTACK_SPEED)
	
	self:InitGenericModifiers()
	
	HeroSelection:StartHeroSelection()
	
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CRaidKings, "OnHeroPick"), CRaidKings )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap(CRaidKings, "FilterOrders"), CRaidKings )
	GameRules:GetGameModeEntity():SetModifierGainedFilter( Dynamic_Wrap(CRaidKings, "FilterModifiers"), CRaidKings )
	
	GameRules:GetGameModeEntity():SetThink( "OnGameThink", self, 0.25 ) 
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(600)
end

function CRaidKings:OnGameThink()
end

function CRaidKings:FilterOrders(event)
	if event.order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then return nil end
	for _, heroID in pairs(event.units) do
		local hero = EntIndexToHScript( heroID )
		if hero and hero:IsRealHero() and not hero.hasSkillsSelected then
			return nil
		end
	end
	return true
end

function CRaidKings:FilterModifiers( filterTable )
	local parent_index = filterTable["entindex_parent_const"]
    local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
    if not parent_index or not caster_index or not ability_index then
        return true
    end
	local duration = filterTable["duration"]
    local parent = EntIndexToHScript( parent_index )
    local caster = EntIndexToHScript( caster_index )
	local ability = EntIndexToHScript( ability_index )
	local name = filterTable["name_const"]

	if parent == caster or not caster or not ability or duration == -1 then return true end
	
	local parentBuffIncrease = 1
	local parentDebuffIncrease = 0
	local casterBuffIncrease = 1
	local casterDebuffIncrease = 1
	
	for _, modifier in pairs( parent:FindAllModifiers() ) do
		if modifier.GetModifierStatusResistance then
			parentDebuffIncrease = parentDebuffIncrease + (1 - parentDebuffIncrease) * (modifier:GetModifierStatusResistance() / 100)
			parentBuffIncrease = parentBuffIncrease + (modifier:GetModifierStatusResistance() / 100)
		end
	end
	for _, modifier in ipairs( caster:FindAllModifiers() ) do
		if modifier.GetModifierStatusAmplification then
			casterBuffIncrease = casterBuffIncrease + (modifier:GetModifierStatusAmplification() / 100)
			casterDebuffIncrease = casterDebuffIncrease + (modifier:GetModifierStatusAmplification() / 100)
		end
	end
	Timers:CreateTimer(0,function()
		if parent and not parent:IsNull() then
			local modifier = parent:FindModifierByNameAndCaster(name, caster)
			if modifier and not modifier:IsNull() then
				if modifier.IsDebuff or parent:GetTeam() ~= caster:GetTeam() and (parentDebuffIncrease < 1 or casterDebuffIncrease > 1) then
					local duration = modifier:GetRemainingTime()
					modifier:SetDuration(duration * math.max(0, (1 - parentDebuffIncrease) * casterDebuffIncrease), true)
				elseif modifier.IsBuff or parent:GetTeam() == caster:GetTeam() and (parentBuffIncrease > 1 or casterBuffIncrease > 1) then
					local duration = modifier:GetRemainingTime()
					modifier:SetDuration(duration * math.max(0, parentBuffIncrease * casterBuffIncrease), true)
				end
			end
		end
	end)
	return true
end

function CRaidKings:InitGenericModifiers()
	LinkLuaModifier( "modifier_dazed_generic", "libraries/modifiers/modifier_dazed_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_generic_barrier", "libraries/modifiers/modifier_generic_barrier.lua" ,LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_stunned_generic", "libraries/modifiers/modifier_stunned_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_invisibility_custom", "libraries/modifiers/modifier_invisibility_custom.lua" ,LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_shadow_clone", "libraries/modifiers/modifier_shadow_clone.lua" ,LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_wearable", "libraries/modifiers/modifier_wearable.lua" ,LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_chill_generic", "libraries/modifiers/modifier_chill_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_frozen_generic", "libraries/modifiers/modifier_frozen_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
end

function CRaidKings:OnHeroPick(event)
	if not event.heroindex then return end
	local hero = EntIndexToHScript(event.heroindex)
	if not hero or hero:GetName() == "npc_dota_hero_wisp" then return end
	print("Hero loaded in: "..hero:GetName())
	for i = 0, 17 do
		local skill = hero:GetAbilityByIndex(i)
		if skill and skill:IsInnateAbility() then
			skill:SetLevel(1)
		end
	end
	
	for i=0, 9 do
		local current_item = hero:GetItemInSlot(i)
		if current_item	then
			hero:RemoveItem(current_item)
		end
	end
	
	StatsManager:CreateCustomStatsForHero(hero)
	ItemManager(hero, GameRules.UnitKV[hero:GetUnitName()]["Items"])
end
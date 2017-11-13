MAXIMUM_ATTACK_SPEED	= 700
MINIMUM_ATTACK_SPEED	= 20

ROUND_END_DELAY = 3

DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2


CUSTOM_GAME_STATE_HERO_SELECTION = 1
CUSTOM_GAME_STATE_SKILL_SELECTION = 2
CUSTOM_GAME_STATE_GAME = 3
HERO_SELECTION_TIME = 80

MAP_CENTER = Vector(332, -1545)

if CRaidKings == nil then
	CRaidKings = class({})
end

require( "abilitymanager" )

require( "libraries/Timers" )
require( "libraries/notifications" )
require("libraries/utility")
require("libraries/animations")

-- require("relics/relic")
-- require("relics/relicpool")

-- Precache resources
function Precache( context )
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
	GameRules.abilityManager = AbilityManager()
	
	-- Load unit KVs into main kv
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	
	GameRules.HeroList = LoadKeyValues("scripts/npc/activelist.txt")
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
	
	
	CustomGameEventManager:RegisterListener('QueryHeroInformation', Context_Wrap( CRaidKings, 'ProcessHeroInformation'))
	CustomGameEventManager:RegisterListener('TryConfirmHero', Context_Wrap( CRaidKings, 'TryConfirmHero'))
	CustomGameEventManager:RegisterListener('TryRandomHero', Context_Wrap( CRaidKings, 'TryRandomHero'))
	CustomNetTables:SetTableValue("hero_selection", "hasPlayerSelected", {})
	CustomNetTables:SetTableValue("hero_selection", "heroPickPhaseParams", {pickTimeRemaining = HERO_SELECTION_TIME})
	GameRules.gameState = CUSTOM_GAME_STATE_HERO_SELECTION
	
	GameRules:GetGameModeEntity():SetThink( "HeroSelectionPhase", self, 0.25 ) 
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CRaidKings, "OnHeroPick"), CRaidKings )
end

function CRaidKings:OnHeroPick(event)
	local hero = EntIndexToHScript(event.heroindex)
	if not hero or hero:GetName() == "npc_dota_hero_wisp" then return end
end

function CRaidKings:HeroSelectionPhase()
	if GameRules:IsGamePaused() then return 0.25 end
	local pickParams = CustomNetTables:GetTableValue("hero_selection", "heroPickPhaseParams") or {}
	pickParams.pickTimeRemaining = math.max(0, (pickParams.pickTimeRemaining or HERO_SELECTION_TIME) - 0.25)

	if not pickParams.heroPickPhaseFinished then
		if tonumber(pickParams.pickTimeRemaining) <= 0 then
			pickParams.heroPickPhaseFinished = true
		end
		CustomNetTables:SetTableValue("hero_selection", "heroPickPhaseParams", pickParams)
		return 0.25
	else
		for _, hero in ipairs(HeroList:GetAllHeroes()) do
			if hero:GetName() == "npc_dota_hero_wisp" then
				self:TryRandomHero(nil, {playerID = hero:GetPlayerID()})
			end
		end
		CustomGameEventManager:Send_ServerToAllClients("EndHeroSelection", {} )
	end
end

function CRaidKings:TryRandomHero(catch, event)
	local pID = event.playerID
	local randomTable = {}
	for hero, id in pairs(GameRules.HeroList) do
		table.insert(randomTable, hero)
	end
	local randomedHero = RandomInt(1, 10)
	local hero = randomTable[randomedHero]
	local data = {}
	data.playerID = pID
	data.heroname = hero
	self:ProcessHeroInformation(catch, data)
	self:TryConfirmHero(catch, data)
end

function CRaidKings:TryConfirmHero(catch, event)
	local pID = event.playerID
	local hero = event.heroname
	local heroUnit = PlayerResource:GetSelectedHeroEntity(pID)
	local playerSelectTable = CustomNetTables:GetTableValue("hero_selection", "hasPlayerSelected") or {}
	playerSelectTable[tostring(pID)] = true
	CustomNetTables:SetTableValue("hero_selection", "hasPlayerSelected", playerSelectTable)
	print(pID, hero)
	CustomGameEventManager:Send_ServerToAllClients("UpdatedHeroSelections", {} )
	PlayerResource:ReplaceHeroWith(pID, hero, 0, 0)
	UTIL_Remove(heroUnit)
	local allPlayersPicked = true
	for _, hero in ipairs( HeroList:GetAllHeroes()) do
		if hero:GetName() == "npc_dota_hero_wisp" then
			allPlayersPicked = false
		end
	end
	Timers:CreateTimer(1, function () 
		if allPlayersPicked then
			local pickParams = CustomNetTables:GetTableValue("hero_selection", "heroPickPhaseParams") or {}
			pickParams.heroPickPhaseFinished = true
			CustomNetTables:SetTableValue("hero_selection", "heroPickPhaseParams", pickParams)
			CustomGameEventManager:Send_ServerToAllClients("EndHeroSelection", {} )
		end
	end)
end

function CRaidKings:ProcessHeroInformation(catch, event)
	local pID = event.playerID
	local hero = event.heroname
	local player = PlayerResource:GetPlayer(pID)
	CustomGameEventManager:Send_ServerToAllClients("UpdatedHeroSelections", {} )
	if player and tonumber(CustomNetTables:GetTableValue("hero_selection", "hasPlayerSelected")[tostring(pID)]) ~= 1 then
		local selectedHeroes = CustomNetTables:GetTableValue("hero_selection", "selected_heroes") or {}
		selectedHeroes[tostring(pID)] = hero
		CustomNetTables:SetTableValue("hero_selection", "selected_heroes", selectedHeroes)
		data = {}
		data.heroName = hero
		data.roleStrength = GameRules.UnitKV[hero]["HeroValues"]
		data.innateAbility = GameRules.UnitKV[hero]["Ability4"]
		data.abilityList = GameRules.UnitKV[hero]["Abilities"]
		CustomGameEventManager:Send_ServerToPlayer( player, "SendHeroProcessedInformation", data )
	end
end
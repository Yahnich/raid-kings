if HeroSelection == nil then
	print ( 'creating hero selection manager' )
	HeroSelection = {}
	HeroSelection.__index = HeroSelection
end

function HeroSelection:new( o )
	o = o or {}
	setmetatable( o, HeroSelection )
	return o
end

HERO_SELECTION_TIME = _G["HERO_SELECTION_TIME"]

function HeroSelection:StartHeroSelection()
	HeroSelection = self
  
	self.queryListener = CustomGameEventManager:RegisterListener('QueryHeroInformation', Context_Wrap( HeroSelection, 'ProcessHeroInformation'))
	self.confirmListener = CustomGameEventManager:RegisterListener('TryConfirmHero', Context_Wrap( HeroSelection, 'TryConfirmHero'))
	self.randomListener = CustomGameEventManager:RegisterListener('TryRandomHero', Context_Wrap( HeroSelection, 'TryRandomHero'))
	CustomNetTables:SetTableValue("hero_selection", "hasPlayerSelected", {})
	CustomNetTables:SetTableValue("hero_selection", "heroPickPhaseParams", {pickTimeRemaining = HERO_SELECTION_TIME})
	GameRules.gameState = CUSTOM_GAME_STATE_HERO_SELECTION
	
	GameRules:GetGameModeEntity():SetThink( "HeroSelectionPhase", self, 0.25 ) 
end


function HeroSelection:HeroSelectionPhase()
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
		CustomGameEventManager:UnregisterListener(self.queryListener)
		CustomGameEventManager:UnregisterListener(self.confirmListener)
		CustomGameEventManager:UnregisterListener(self.randomListener)
		
		local pickParams = CustomNetTables:GetTableValue("hero_selection", "heroPickPhaseParams") or {}
		pickParams.heroPickPhaseFinished = true
		CustomNetTables:SetTableValue("hero_selection", "heroPickPhaseParams", pickParams)
		
		StatsManager:start()
		
		CustomGameEventManager:Send_ServerToAllClients("EndHeroSelection", {} )
		SkillSelection:StartSkillSelection()
	end
end

function HeroSelection:TryRandomHero(userid, event)
	local pID = event.playerID
	if PlayerResource:GetSelectedHeroEntity(pID):GetUnitName() ~= "npc_dota_hero_wisp" then return end
	local randomTable = {}
	for hero, id in pairs(GameRules.HeroList) do
		table.insert(randomTable, hero)
	end
	local randomedHero = RandomInt(1, 10)
	local hero = randomTable[randomedHero]
	local data = {}
	data.playerID = pID
	data.heroname = hero
	self:ProcessHeroInformation(userid, data)
	self:TryConfirmHero(userid, data)
end

function HeroSelection:TryConfirmHero(userid, event)
	local pID = event.playerID
	local hero = event.heroname
	local heroUnit = PlayerResource:GetSelectedHeroEntity(pID)
	local playerSelectTable = CustomNetTables:GetTableValue("hero_selection", "hasPlayerSelected") or {}
	playerSelectTable[tostring(pID)] = true
	CustomNetTables:SetTableValue("hero_selection", "hasPlayerSelected", playerSelectTable)

	CustomGameEventManager:Send_ServerToAllClients("UpdatedHeroSelections", {} )
	PlayerResource:ReplaceHeroWith(pID, hero, 0, 0)
	UTIL_Remove(heroUnit)

	local abilityList = GameRules.UnitKV[hero]["Abilities"]
	local innateAbility = GameRules.UnitKV[hero]["Ability4"]
	
	local skillTable = {}
	local id = 1
	for ability,_ in pairs(abilityList) do
		skillTable["ability"..id] = ability
		id = id + 1
	end
	skillTable["innate"] = innateAbility
	
	local hotkeyTable = {
		["Q"] = "no_ability",
		["W"] = "no_ability",
		["E"] = "no_ability",
		["R"] = "no_ability",
	}
	
	CustomNetTables:SetTableValue("skill_selection", "skill_list_playerid"..pID, skillTable)
	CustomNetTables:SetTableValue("skill_selection", "selected_list_playerid"..pID, hotkeyTable)
	
	local allPlayersPicked = true
	for _, hero in ipairs( HeroList:GetAllHeroes()) do
		if hero:GetName() == "npc_dota_hero_wisp" then
			allPlayersPicked = false
			break
		end
	end
	if allPlayersPicked then
		CustomGameEventManager:Send_ServerToAllClients("StartSkillSelection", {} )
		Timers:CreateTimer(1, function () 
			local pickParams = CustomNetTables:GetTableValue("hero_selection", "heroPickPhaseParams") or {}
			pickParams.heroPickPhaseFinished = true
			CustomNetTables:SetTableValue("hero_selection", "heroPickPhaseParams", pickParams)
		end)
	end
end

function HeroSelection:ProcessHeroInformation(userid, event)
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
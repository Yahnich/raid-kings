if SkillSelection == nil then
  print ( 'creating skill selection manager' )
  SkillSelection = {}
  SkillSelection.__index = SkillSelection
end

function SkillSelection:new( o )
  o = o or {}
  setmetatable( o, SkillSelection )
  return o
end

SKILL_SELECTION_TIME = _G["SKILL_SELECTION_TIME"]

function SkillSelection:StartSkillSelection()
	SkillSelection = self
	self.queryListener = CustomGameEventManager:RegisterListener('RefreshSkills', Context_Wrap( SkillSelection, 'ProcessSkillInformation'))
	self.confirmListener = CustomGameEventManager:RegisterListener('TryConfirmSkills', Context_Wrap( SkillSelection, 'TryConfirmSkills'))
	self.randomListener = CustomGameEventManager:RegisterListener('TryRandomSkills', Context_Wrap( SkillSelection, 'TryRandomSkills'))
	
	CustomNetTables:SetTableValue("skill_selection", "hasPlayerSelected", {})
	CustomNetTables:SetTableValue("skill_selection", "skillPickPhaseParams", {pickTimeRemaining = HERO_SELECTION_TIME})
	GameRules.gameState = CUSTOM_GAME_STATE_SKILL_SELECTION
	
	GameRules:GetGameModeEntity():SetThink( "SkillSelectionPhase", self, 0.25 ) 
end

function SkillSelection:SkillSelectionPhase()
	if GameRules:IsGamePaused() then return 0.25 end
	local pickParams = CustomNetTables:GetTableValue("skill_selection", "skillPickPhaseParams") or {}
	pickParams.pickTimeRemaining = math.max(0, (pickParams.pickTimeRemaining or HERO_SELECTION_TIME) - 0.25)
	if not pickParams.skillPickPhaseFinished then
		if tonumber(pickParams.pickTimeRemaining) <= 0 then
			pickParams["skillPickPhaseFinished"] = true
		end
		CustomNetTables:SetTableValue("skill_selection", "skillPickPhaseParams", pickParams)
		return 0.25
	else	
		local selectedSkills = CustomNetTables:GetTableValue("skill_selection", "hasPlayerSelected")
		for _, hero in ipairs(HeroList:GetAllHeroes()) do
			if not selectedSkills[hero:GetPlayerID()] then
				self:TryRandomSkills(nil, {playerID = hero:GetPlayerID()})
			end
		end
		CustomGameEventManager:UnregisterListener(self.queryListener)
		CustomGameEventManager:UnregisterListener(self.confirmListener)
		CustomGameEventManager:UnregisterListener(self.randomListener)
		
		
		
		CustomGameEventManager:Send_ServerToAllClients("EndSkillSelection", {} )
	end
end

function SkillSelection:ProcessSkillInformation(userid, event)
	local pID = event.playerID
	local orderedList = event.hotkeyList
	
	local hotKeysEnums = {
		["0"] = "Q",
		["1"] = "W",
		["2"] = "E",
		["3"] = "R",
	}
	
	local hotkeyList = CustomNetTables:GetTableValue("skill_selection", "selected_list_playerid"..pID) or {}

	for id, ability in pairs(orderedList) do
		hotkeyList[hotKeysEnums[id]] = ability
	end

	CustomNetTables:SetTableValue("skill_selection", "selected_list_playerid"..pID, hotkeyList)
	CustomGameEventManager:Send_ServerToAllClients("UpdatedSkillSelections", {playerID = pID} )

end

function SkillSelection:TryConfirmSkills(userid, event)
	local pID = event.playerID
	local abilityList = CustomNetTables:GetTableValue("skill_selection", "selected_list_playerid"..pID) or {}

	local player = PlayerResource:GetPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID) 
	if not hero then return nil end
	local trueCount = 0
	local orderedList = {}
	
	local hotKeysEnums = {
		["Q"] = 1,
		["W"] = 2,
		["E"] = 3,
		["R"] = 4,
	}
	
	for index, ability in pairs(abilityList) do
		if ability ~= "no_ability" then
			orderedList[hotKeysEnums[index]] = ability
			trueCount = trueCount + 1
		end
	end
	if trueCount == 4 then
		hero.abilityIndexingList = orderedList
		self:LoadHeroSkills(hero)
		hero.HasBeenInitialized = true
		hero.hasSkillsSelected = true
		local selectedPlayers = CustomNetTables:GetTableValue("skill_selection", "hasPlayerSelected")
		selectedPlayers[tostring(pID)] = true
		allPlayersDone = true
		for _, hero in ipairs(HeroList:GetAllHeroes()) do
			if not selectedPlayers[tostring(hero:GetPlayerID())] then
				allPlayersDone = false
				break
			end
		end
		
		if allPlayersDone then
			local pickParams = {}
			pickParams["skillPickPhaseFinished"] = true
			CustomNetTables:SetTableValue("skill_selection", "skillPickPhaseParams", pickParams)
		end
		
		CustomNetTables:SetTableValue("skill_selection", "hasPlayerSelected", selectedPlayers)
		CustomGameEventManager:Send_ServerToPlayer(player, "EndSkillSelection", {})
	end
end

function SkillSelection:TryRandomSkills(userid, event)
	local pID = event.playerID
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	if not hero then return end
	
	local hotkeyList = CustomNetTables:GetTableValue("skill_selection", "selected_list_playerid"..pID) or {}
	local abilityList = GameRules.UnitKV[hero:GetUnitName()]["Abilities"]
	local abCount = 0
	for hotkey,ability in pairs(hotkeyList) do
		if abilityList[ability] then
			abilityList[ability] = nil
		else
			abCount = abCount + 1
		end
	end
	for hotkey, ability in pairs(hotkeyList) do
		if ability == "no_ability" then
			local internalCounter = 0
			for newAb,_ in pairs(abilityList) do
				if RollPercentage(100/(abCount-internalCounter)) then
					hotkeyList[hotkey] = newAb
					abilityList[newAb] = nil
					abCount = abCount - 1
					break
				else
					internalCounter = internalCounter + 1
				end
			end
		end
	end
	CustomNetTables:SetTableValue("skill_selection", "selected_list_playerid"..pID, hotkeyList)
	self:TryConfirmSkills(userid, {playerID = pID})
end

function SkillSelection:LoadHeroSkills(hero)
	for i = 0, #hero.abilityIndexingList do
		local index = self:FindNextAbilityIndex(hero)
		local ability = hero.abilityIndexingList[i]
		
		if ability and index then
			hero:RemoveAbility(hero:GetAbilityByIndex(index):GetName())
			hero:AddAbilityPrecache(ability):SetAbilityIndex(index)
			print(ability)
		end
	end
end

function SkillSelection:FindNextAbilityIndex(hero)
	for i = 0, 23 do
		if hero:GetAbilityByIndex(i) then
			if string.match(hero:GetAbilityByIndex(i):GetName(), "empty") then
				return i 
			end
		end
	end
end
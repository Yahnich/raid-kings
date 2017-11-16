"use strict";

(function(){
	// Fix DOTA buttons
	var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()
	var settingsCont = dotaHud.FindChildTraverse("HUDElements")
	settingsCont.style.zIndex = 999
	
	var heroSelectionDone = CustomNetTables.GetTableValue("hero_selection", "heroPickPhaseParams")
	if( heroSelectionDone["heroPickPhaseFinished"] != 1 ){
		var playerCount = Game.GetAllPlayerIDs();

		for (var pID of playerCount){
			CreateHeroPortrait(pID);
		}
		
		var preFilterHeroes = CustomNetTables.GetTableValue( "hero_selection", "herolist" );

		var internalCounter = 1;
		var rows = 1;
		var rowID = "HeroContainerRow"+rows;
		
		var parentPanel = $("#HeroContainer");
		
		var heroRow = $.CreatePanel( "Panel", parentPanel, rowID);
		heroRow.AddClass("HeroRoleContainerRow");
		
		for (var index in preFilterHeroes) {
			CreateSelectableHero(preFilterHeroes[index], heroRow	);
			if(internalCounter++ >= 5){
				rows++;
				internalCounter = 0
				heroRow = $.CreatePanel( "Panel", parentPanel, "HeroContainerRow"+rows);
				heroRow.AddClass("HeroRoleContainerRow");
			}
		}
		
		UpdateHeroSelectionTimer()
	} else {
		EndHeroSelection(null)
	}
})();

var heroCallback = CustomNetTables.SubscribeNetTableListener( "hero_selection", UpdateHeroSelectionTimer);

function UpdateHeroSelectionTimer(){
	var heroTimer = CustomNetTables.GetTableValue("hero_selection", "heroPickPhaseParams")
	var timeLeft = heroTimer["pickTimeRemaining"]
	$("#SelectionTimer").text = Math.ceil(timeLeft)
}

function CreateHeroPortrait(i){
	var newHeroPanel = $.CreatePanel( "DOTAHeroMovie", $("#HeroPortraitHolder"), "HeroPortraitPlayerID"+i);
	newHeroPanel.AddClass("SelectedHeroPortrait")
	var heroSelectionTable = CustomNetTables.GetTableValue( "hero_selection", "selected_heroes" )
	var hasHeroBeenConfirmed = CustomNetTables.GetTableValue( "hero_selection", "hasPlayerSelected" )
	if(heroSelectionTable == null || (hasHeroBeenConfirmed == null || hasHeroBeenConfirmed[i] == false )){newHeroPanel.AddClass("HeroUnselected")}
	newHeroPanel.heroname = "npc_dota_hero_wisp"
	if(heroSelectionTable != null && heroSelectionTable[i] != null){
		newHeroPanel.heroname = heroSelectionTable[i]
	}
}

function CreateSelectableHero(heroName, row){
	var newHeroPanel = $.CreatePanel( "DOTAHeroImage", row, heroName);
	newHeroPanel.AddClass("SelectedableHero")
	newHeroPanel.heroname = heroName

	newHeroPanel.SetCurrentActiveHero = function SetCurrentActiveHero(){
		var id = Game.GetLocalPlayerID()
		QueryHeroInformation(newHeroPanel.heroname, id)
	}
	newHeroPanel.SetPanelEvent("onactivate", newHeroPanel.SetCurrentActiveHero );
}

function QueryHeroInformation(heroname, id){
	GameEvents.SendCustomGameEventToServer( "QueryHeroInformation", {playerID : id, heroname : "npc_dota_hero_"+heroname } );
}

GameEvents.Subscribe( "SendHeroProcessedInformation", UpdateHeroSelection);
GameEvents.Subscribe( "UpdatedHeroSelections", RefreshHeroPortraits);
GameEvents.Subscribe( "EndHeroSelection", EndHeroSelection);

function EndHeroSelection(args){
	CustomNetTables.UnsubscribeNetTableListener( heroCallback )
	$.GetContextPanel().DeleteAsync(1)
}


function RefreshHeroPortraits(args){
	var selectedHeroes = CustomNetTables.GetTableValue( "hero_selection", "selected_heroes" );
	var hasHeroBeenConfirmed = CustomNetTables.GetTableValue( "hero_selection", "hasPlayerSelected" )
	for (var pID in selectedHeroes){
		$("#HeroPortraitPlayerID"+pID).heroname = selectedHeroes[pID]
		var heroPicked =  (hasHeroBeenConfirmed == null || hasHeroBeenConfirmed[pID] != 1 )
		$("#HeroPortraitPlayerID"+pID).SetHasClass( "HeroUnselected", heroPicked )
	}
}

function UpdateHeroSelection(args){
	var heroname = args.heroName
	var abilities = args.abilityList
	var roles = args.roleStrength
	var innate = args.innateAbility
	
	$("#HeroPortrait").heroname = heroname

	var parentLabel
	
	$("#DamageRoleLabel").text = ""
	$("#TankRoleLabel").text = ""
	$("#UtilityRoleLabel").text = ""
	for (var index in roles){
		var roleStrength = parseInt(roles[index])
		if(index == "Damage"){
			parentLabel = $("#DamageRoleLabel")
		} else if(index == "Support"){
			parentLabel = $("#UtilityRoleLabel")
		} else if(index == "Tank"){
			parentLabel = $("#TankRoleLabel")
		}
		for (var i = 0; i < roleStrength; i++){
			parentLabel.text = parentLabel.text + "  |"
		}
	}
	$("#HeroInfoName").text =  "The " + $.Localize( "#"+heroname );
	var abId = 1
	for (var ability in abilities){
		var abilityPanel = $("#AbilitySlot"+abId)
		RefreshAbilitySlot(abilityPanel, ability)
		abId++
	}
	RefreshAbilitySlot($("#AbilitySlotInnate"), innate)
	$("#HeroInfoMain").text = $.Localize( "#Description_"+heroname );
}

function RefreshAbilitySlot(panel, ability){
	panel.abilityname = ability
	panel.showTooltip = function(){
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", panel, panel.abilityname, Game.GetLocalPlayerID());
	}
	panel.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", panel);
	}
	panel.SetPanelEvent("onmouseover", panel.showTooltip );
	panel.SetPanelEvent("onmouseout", panel.hideTooltip );
}

function ConfirmHeroSelection(){
	var selectionTable = CustomNetTables.GetTableValue( "hero_selection", "selected_heroes" )
	var localID = Game.GetLocalPlayerID()
	var currHeroPicked = (selectionTable != null && selectionTable[localID] != null)
	if(currHeroPicked){
		GameEvents.SendCustomGameEventToServer( "TryConfirmHero", {playerID : localID, heroname : selectionTable[localID] } );
	}
}

function RandomHeroSelection(){
	var localID = Game.GetLocalPlayerID()
	GameEvents.SendCustomGameEventToServer( "TryRandomHero", {playerID : localID} );
}
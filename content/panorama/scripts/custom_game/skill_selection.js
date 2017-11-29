"use strict";
var localID = Game.GetLocalPlayerID();
var currentDragPanel;

var skillCallback = CustomNetTables.SubscribeNetTableListener( "skill_selection", UpdateSkillSelectionTimer )

GameEvents.Subscribe( "UpdatedSkillSelections", RefreshSkillContainers);
GameEvents.Subscribe( "StartSkillSelection", SetSkillContainers);
GameEvents.Subscribe( "EndSkillSelection", EndSkillSelection);



function UpdateSkillSelectionTimer(){
	var skillTimer = CustomNetTables.GetTableValue("skill_selection", "skillPickPhaseParams")
	var timeLeft = skillTimer["pickTimeRemaining"]
	$("#SelectionTimer").text = Math.ceil(timeLeft)
}

function ConfirmSkillSelection()
{
	GameEvents.SendCustomGameEventToServer( "TryConfirmSkills", {playerID : localID});
}

function RandomSkillSelection(){
	GameEvents.SendCustomGameEventToServer( "TryRandomSkills", {playerID : localID} );
}

function SetSkillContainers(args){
	var playerCount = Game.GetAllPlayerIDs();
	for (var pID of playerCount){
		var skillList = CustomNetTables.GetTableValue( "skill_selection", "skill_list_playerid"+pID )
		for(var i = 1; i <= 8; i++){
			(function(){
				var ability =  $("#HeroPreviewAbility"+i+"PlayerID"+pID)
				if(skillList != null && skillList["ability"+i] != null){
					ability.abilityname = skillList["ability"+i]
				}
				ability.showTooltip = function(){
					$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", ability, ability.abilityname, Players.GetPlayerHeroEntityIndex( localID ));
				}
				ability.hideTooltip = function(){ 
					$.DispatchEvent("DOTAHideAbilityTooltip", ability);
				}
				ability.SetPanelEvent("onmouseover", ability.showTooltip );
				ability.SetPanelEvent("onmouseout", ability.hideTooltip );
			})();
		}
		var innate = $("#HeroPreviewInnatePlayerID"+pID)
		if(skillList != null && skillList["innate"] != null){
			innate.abilityname = skillList["innate"]
		}
		innate.hideTooltip = function(){ 
			$.DispatchEvent("DOTAHideAbilityTooltip", innate);
		}
		innate.SetPanelEvent("onmouseover", innate.showTooltip );
		innate.SetPanelEvent("onmouseout", innate.hideTooltip );
		
		var heroSelectionTable = CustomNetTables.GetTableValue( "hero_selection", "selected_heroes" )
		var portrait = $("#HeroPortraitPlayerID"+pID)
		if(heroSelectionTable != null && heroSelectionTable[pID] != null){
			portrait.heroname = heroSelectionTable[pID]
		}
	}
}


(function(){
	// Create base HUD
	var skillSelectionDone = CustomNetTables.GetTableValue("skill_selection", "skillPickPhaseFinished")
	if( skillSelectionDone == null || skillSelectionDone["skillPickPhaseFinished"] != 1 ){
		var playerCount = Game.GetAllPlayerIDs();

		for (var pID of playerCount){
			CreateSkillContainer(pID);
			var seperator = $.CreatePanel( "Panel", $("#HeroRowContainer"), "HorizontalSeperator"+pID);
			seperator.AddClass("HorizontalSeperator")
		}
		UpdateSkillSelectionTimer()
	} else {
		EndSkillSelection([])
	}
})();

function EndSkillSelection(args){
	var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements");
	dotaHud.style.zIndex = 0;
	CustomNetTables.UnsubscribeNetTableListener( skillCallback )
	if(currentDragPanel != null){currentDragPanel.DeleteAsync(0)}
	$.GetContextPanel().DeleteAsync(0)
	
	var minimapCont = dotaHud.FindChildTraverse("minimap_container");
	minimapCont.style.align = "right top";
	dotaHud.FindChildTraverse("minimap_block").style.align = "right top";
	dotaHud.FindChildTraverse("minimap").style.align = "right top";
}

function CreateSkillContainer(id){
	// init vars
	var heroSelectionTable = CustomNetTables.GetTableValue( "hero_selection", "selected_heroes" )
	
	// Create main container
	var mainContainer = $.CreatePanel( "Panel", $("#HeroRowContainer"), "HeroSkillRowPlayerID"+id);
	mainContainer.AddClass("SkillMainContainerRow")
	// Create hero portrait
	var heroPortrait = $.CreatePanel( "DOTAHeroImage", mainContainer, "HeroPortraitPlayerID"+id);
	heroPortrait.AddClass("HeroIcon")
	
	heroPortrait.heroname = "npc_dota_hero_wisp"
	if(heroSelectionTable != null && heroSelectionTable[id] != null){
		heroPortrait.heroname = heroSelectionTable[id]
	}
	
	var innate = $.CreatePanel( "DOTAAbilityImage", mainContainer, "HeroPreviewInnatePlayerID"+id);
	innate.AddClass("AbilityIcon")
	innate.abilityname = "no_ability"
	var skillList = CustomNetTables.GetTableValue( "skill_selection", "skill_list_playerid"+id )
	if(skillList != null && skillList["innate"] != null){
		innate.abilityname = skillList["innate"]
	}
	
	innate.showTooltip = function(){
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", innate, innate.abilityname, Players.GetPlayerHeroEntityIndex( localID ));
	}
	innate.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", innate);
	}
	innate.SetPanelEvent("onmouseover", innate.showTooltip );
	innate.SetPanelEvent("onmouseout", innate.hideTooltip );
	
	var skillContainer = $.CreatePanel( "Panel", mainContainer, "HeroSelectedSkillContainersPlayerID"+id);
	skillContainer.AddClass("SkillAbilityContainerRow")
	
	CreateSelectableSkillContainer("Q", id)
	CreateSelectableSkillContainer("W", id)
	CreateSelectableSkillContainer("E", id)
	CreateSelectableSkillContainer("R", id)
	
	var previewContainer = $.CreatePanel( "Panel", mainContainer, "HeroPreviewContainerPlayerID"+id);
	previewContainer.AddClass("SelectablePreviewContainerRow")
	
	var previewSkillContainer = $.CreatePanel( "Panel", previewContainer, "PreviewSkillContainerPlayerID"+id);
	previewSkillContainer.AddClass("SelectableSkillContainer")
	
	for(var i = 1; i <= 8; i++){
		CreatePreviewAbility(i, id)
	}
}

function RefreshSkillContainers(args)
{
	var pID = args.playerID
	var skillList = CustomNetTables.GetTableValue("skill_selection", "selected_list_playerid" + pID );
	for(var hotkey in skillList){
		(function(){
			var abilityHotkey = $("#HeroSelectedSkillHotkey" + hotkey + "PlayerID"+pID)
			abilityHotkey.abilityname = skillList[hotkey]
			abilityHotkey.showTooltip = function(){
				if(abilityHotkey.abilityname != "no_ability"){ $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", abilityHotkey, abilityHotkey.abilityname, Players.GetPlayerHeroEntityIndex( localID )); }
			}
			abilityHotkey.hideTooltip = function(){ 
				$.DispatchEvent("DOTAHideAbilityTooltip", abilityHotkey);
			}
			abilityHotkey.SetPanelEvent("onmouseover", abilityHotkey.showTooltip );
			abilityHotkey.SetPanelEvent("onmouseout", abilityHotkey.hideTooltip );
		})()
	}
}

function CreateSelectableSkillContainer(hotkey, id){
	var selectedSkills = CustomNetTables.GetTableValue("skill_selection", "selected_list_playerid" + id );
	var abilityHotkey = $.CreatePanel( "DOTAAbilityImage", $("#HeroSelectedSkillContainersPlayerID"+id), "HeroSelectedSkillHotkey" + hotkey + "PlayerID"+id);
	abilityHotkey.AddClass("AbilityIcon")
	abilityHotkey.abilityname = "no_ability"
	if(selectedSkills != null && selectedSkills[hotkey] != ""){
		abilityHotkey.abilityname = selectedSkills[hotkey]
	}
	abilityHotkey.showTooltip = function(){
		if(abilityHotkey.abilityname != "no_ability"){ $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", abilityHotkey, abilityHotkey.abilityname, Players.GetPlayerHeroEntityIndex( localID )); }
	}
	abilityHotkey.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", abilityHotkey);
	}
	abilityHotkey.SetPanelEvent("onmouseover", abilityHotkey.showTooltip );
	abilityHotkey.SetPanelEvent("onmouseout", abilityHotkey.hideTooltip );
	
	
	var abilityHotkeyFlair = $.CreatePanel( "Panel", abilityHotkey, "HeroSelectedSkillHotkeyFlair" + hotkey + "PlayerID"+id);
	abilityHotkeyFlair.AddClass("AbilityHotkeyFlair")
	
	var abilityHotkeyLabel = $.CreatePanel( "Label", abilityHotkeyFlair, "HeroSelectedSkillHotkeyLabel" + hotkey + "PlayerID"+id);
	abilityHotkeyLabel.AddClass("HotkeyLabel")
	abilityHotkeyLabel.text = hotkey
	
	
	if(id == localID){
		abilityHotkey.OnDragEnter = function( a, draggedPanel )
		{
			abilityHotkey.AddClass( "AbilitySelected" );
			return true;
		}
		abilityHotkey.OnDragDrop = function( panelId, draggedPanel ){
			abilityHotkey.RemoveClass( "AbilitySelected" );
			var found = false;
			var sisterPanel;
			var slots = abilityHotkey.GetParent().Children()
			slots.forEach(function(abilityHotkey, index){
				if(abilityHotkey.abilityname == draggedPanel.abilityname){
					found = true;
					sisterPanel = abilityHotkey;
				}
			})
			if( found ){
				sisterPanel.abilityname = abilityHotkey.abilityname
			}
			abilityHotkey.abilityname = draggedPanel.abilityname
			abilityHotkey.SetDraggable(true)
			
			var list = []
			var qwer = abilityHotkey.GetParent().Children()
			qwer.forEach(function(abilityHotkey, index){
				list.push(abilityHotkey.abilityname)
			})
			
			GameEvents.SendCustomGameEventToServer( "RefreshSkills", {playerID : id, hotkeyList : list });
			
			return true;
		}
		abilityHotkey.OnDragLeave = function( panelId, draggedPanel )
		{
			abilityHotkey.RemoveClass( "AbilitySelected" );
			return true;
		}
		
		abilityHotkey.OnDragStart = function( panelId, dragCallbacks ){
			if(abilityHotkey.abilityname != "no_ability" ){
				var dummyPanel = $.CreatePanel( "DOTAAbilityImage", abilityHotkey, abilityHotkey.abilityname+"_dummy" );
				dummyPanel.AddClass("AbilityIcon");
				dummyPanel.abilityname = abilityHotkey.abilityname;
				
				abilityHotkey.hideTooltip()
				abilityHotkey.abilityname = "no_ability"
				abilityHotkey.SetDraggable(false)
				dragCallbacks.displayPanel = dummyPanel;
				dragCallbacks.offsetX = 0;
				dragCallbacks.offsetY = 400;
				
				currentDragPanel = dummyPanel
				
				return true;
			} else { return false; }
		}
		abilityHotkey.OnDragEnd = function( panelId, draggedPanel  ){
			currentDragPanel = null
			draggedPanel.DeleteAsync( 0 );
			return true;
		}
		
		$.RegisterEventHandler( 'DragEnter', abilityHotkey, abilityHotkey.OnDragEnter );
		$.RegisterEventHandler( 'DragDrop', abilityHotkey, abilityHotkey.OnDragDrop );
		$.RegisterEventHandler( 'DragLeave', abilityHotkey, abilityHotkey.OnDragLeave );
		$.RegisterEventHandler( 'DragStart', abilityHotkey, abilityHotkey.OnDragStart );
		$.RegisterEventHandler( 'DragEnd', abilityHotkey, abilityHotkey.OnDragEnd );
		
		var skillList = CustomNetTables.GetTableValue("skill_selection", "selected_list_playerid" + id );
		
		if(skillList != null && skillList[hotkey] != "no_ability"){
			abilityHotkey.SetDraggable(true)
		}
	}
}

function CreatePreviewAbility(index, id){
	var skillList = CustomNetTables.GetTableValue( "skill_selection", "skill_list_playerid"+id )
	
	var ability = $.CreatePanel( "DOTAAbilityImage", $("#PreviewSkillContainerPlayerID"+id), "HeroPreviewAbility"+index+"PlayerID"+id);
	ability.AddClass("SelectableAbilityIcon")
	ability.abilityname = "no_ability"
	if(skillList != null && skillList["ability"+index] != null){
		ability.abilityname = skillList["ability"+index]
	}	
	ability.showTooltip = function(){
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", ability, ability.abilityname, Players.GetPlayerHeroEntityIndex( localID ));
	}
	ability.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", ability);
	}
	ability.SetPanelEvent("onmouseover", ability.showTooltip );
	ability.SetPanelEvent("onmouseout", ability.hideTooltip );
	
	if(id == localID){
		ability.SetDraggable(true);
		ability.OnDragStart = function( panelId, dragCallbacks ){
			var dummyPanel = $.CreatePanel( "DOTAAbilityImage", ability, ability.abilityname+"_dummy" );
			dummyPanel.AddClass("AbilityIcon");
			dummyPanel.abilityname = ability.abilityname;
			
			dragCallbacks.displayPanel = dummyPanel;
			dragCallbacks.offsetX = 0;
			dragCallbacks.offsetY = 400;
			
			currentDragPanel = dummyPanel;
			
			return true;
		}
		ability.OnDragEnd = function( panelId, draggedPanel  ){
			currentDragPanel = null;
			draggedPanel.DeleteAsync( 0 );
			return true;
		}

		$.RegisterEventHandler( 'DragStart', ability, ability.OnDragStart );
		$.RegisterEventHandler( 'DragEnd', ability, ability.OnDragEnd );
		
	}
}
"use strict";
var localID = Game.GetLocalPlayerID();
(function(){
	// Fix DOTA buttons
	var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements");
	var abilityHud = dotaHud.FindChildTraverse("lower_hud");
	var netgraph = dotaHud.FindChildTraverse("NetGraph");
	var stats = dotaHud.FindChildTraverse("quickstats");
	var topbar = dotaHud.FindChildTraverse("topbar");
	var glyph = dotaHud.FindChildTraverse("GlyphScanContainer");
	
	abilityHud.style.visibility = "collapse";
	netgraph.style.visibility = "collapse";
	stats.style.visibility = "collapse";
	topbar.style.visibility = "collapse";
	glyph.style.visibility = "collapse";
	
	
	var skillSelectionDone = CustomNetTables.GetTableValue("skill_selection", "skillPickPhaseFinished")
	if( (skillSelectionDone != null && skillSelectionDone["skillPickPhaseFinished"] && skillSelectionDone["skillPickPhaseFinished"] == 1) ){
		var minimapCont = dotaHud.FindChildTraverse("minimap_container");
		minimapCont.style.align = "right top";
		dotaHud.FindChildTraverse("minimap_block").style.align = "right top";
		dotaHud.FindChildTraverse("minimap").style.align = "right top";
	}
	
	CreateTeamInfo()
})();

function CreateTeamInfo(){
	var playerCount = Game.GetAllPlayerIDs(); 
	if(playerCount.length > 1){
		for (var pID of playerCount){
			if(pID != localID){CreateInfoContainer(pID);}
		}
	} else {
		$("#GameHudTeamInfo").style.visibility = "collapse"
	}
	UpdateHUD()
}

function CreateInfoContainer(id)
{
	var teamRoot = $("#PlayerContainerTeamInfo");

	var playerContainer =  $.CreatePanel( "Panel", teamRoot, "PlayerInfoContainerPlayer"+id);
	playerContainer.AddClass("PlayerInfoContainer")
	
	var playerPortrait =  $.CreatePanel( "DOTAHeroMovie", playerContainer, "PlayerInfoPortraitPlayer"+id);
	playerPortrait.AddClass("PlayerInfoPortrait")
	var heroID = Players.GetPlayerHeroEntityIndex( id )
	playerPortrait.heroname = Entities.GetUnitName( heroID )
	
	var resourceContainer =  $.CreatePanel( "Panel", playerContainer, "PlayerInfoResourceContainerPlayer"+id);
	resourceContainer.AddClass("PlayerInfoResourceBar")

	
	var healthBarHolder =  $.CreatePanel( "Panel", resourceContainer, "PlayerInfoHealthBarContainerPlayer"+id);
	healthBarHolder.AddClass("PlayerInfoResourcePanel")
	
	var healthBarLabel =  $.CreatePanel( "Label", healthBarHolder, "PlayerInfoHealthBarLabelPlayer"+id);
	healthBarLabel.AddClass("ResourceText")
	healthBarLabel.text = "100%"
	
	var healthBar =  $.CreatePanel( "Panel", healthBarHolder, "PlayerInfoHealthBarPlayer"+id);
	healthBar.AddClass("PlayerInfoHealth")
	
	var manaBarHolder =  $.CreatePanel( "Panel", resourceContainer, "PlayerInfoManaBarContainerPlayer"+id);
	manaBarHolder.AddClass("PlayerInfoResourcePanel")
	
	var manaBarLabel =  $.CreatePanel( "Label", manaBarHolder, "PlayerInfoManaBarLabelPlayer"+id);
	manaBarLabel.AddClass("ResourceText")
	manaBarLabel.text = "100%"
	
	var manaBar =  $.CreatePanel( "Panel", manaBarHolder, "PlayerInfoManaBarPlayer"+id);
	manaBar.AddClass("PlayerInfoMana")
	
	var buffHolder =  $.CreatePanel( "Panel", resourceContainer, "PlayerInfoBuffContainerPlayer"+id);
	buffHolder.AddClass("PlayerInfoBuffDebuffContainer")
}

function UpdateHUD(){
	$.Schedule(0.1, UpdateHUD);
	var playerCount = Game.GetAllPlayerIDs();
	for (var pID of playerCount){
		if(pID != localID){UpdateInfoContainer(pID);}
	}
}

function UpdateInfoContainer(id)
{
	var playerPortrait =  $("#PlayerInfoPortraitPlayer"+id);
	var heroID = Players.GetPlayerHeroEntityIndex( id )
	if(heroID != null){
		playerPortrait.heroname = Entities.GetUnitName( heroID )
		
		var healthBarLabel = $("#PlayerInfoHealthBarLabelPlayer"+id);
		var hpPerc = Entities.GetHealthPercent( heroID )
		healthBarLabel.text = hpPerc+"%"
		
		var healthBar = $("#PlayerInfoHealthBarPlayer"+id);
		healthBar.style.width = hpPerc.toFixed(1)+"%"
		
		var manaBarLabel = $("#PlayerInfoManaBarLabelPlayer"+id);
		var manaPerc = 	Entities.GetMana( heroID ) / Entities.GetMaxMana( heroID ) * 100
		manaBarLabel.text = manaPerc.toFixed(1)+"%"
		
		var manaBar = $("#PlayerInfoManaBarPlayer"+id);
		manaBar.style.width = manaPerc+"%"
		
		var buffContainer = $("#PlayerInfoBuffContainerPlayer"+id);
		for(var buff of buffContainer.Children()){	
			buff.style.visibility = "collapse";
			buff.DeleteAsync(0)
		}
		var buffCount = 0
		for (var i = 0; i < Entities.GetNumBuffs(heroID); i++) {
			var buffID = Entities.GetBuff(heroID, i)
			if (!Buffs.IsHidden(heroID, buffID ) && buffCount < 5){
				CreateBuff(heroID, buffID, id)
			}
		}
	}
}

function CreateBuff(heroID, buffID, id)
{
	var buffContainer = $("#PlayerInfoBuffContainerPlayer"+id);
	var buffHolder = $.CreatePanel( "Panel", buffContainer, "BuffHolder"+Buffs.GetName(heroID, buffID )+"Player"+id);
	buffHolder.AddClass("PlayerInfoModifierHolder")
	var buff =  $.CreatePanel( "DOTAAbilityImage", buffHolder, "Buff"+Buffs.GetName(heroID, buffID )+"Player"+id);
	buffHolder.heroID = heroID;
	buffHolder.buffID = buffID;
	
	var buffBorder =  $.CreatePanel( "Panel", buffHolder, "BuffBorder"+Buffs.GetName(heroID, buffID )+"Player"+id);
	buff.AddClass("PlayerInfoModifier")
	if(Buffs.IsDebuff(heroID, buffID) ){
		buffBorder.AddClass("IsDebuff")
	} else {
		buffBorder.AddClass("IsBuff")
	}
	buff.abilityname = Abilities.GetAbilityName( Buffs.GetAbility(heroID, buffID ) );
	buffHolder.onMouseOver = function()
	{
		var queryUnit = buffHolder.heroID;
		var buffSerial = buffHolder.buffID
		var isEnemy = Entities.IsEnemy( queryUnit );
		$.DispatchEvent( "DOTAShowBuffTooltip", buffHolder, queryUnit, buffSerial, isEnemy );
	}

	buffHolder.onMouseOut = function()
	{
		$.DispatchEvent( "DOTAHideBuffTooltip", buffHolder );
	}
	
	buffHolder.SetPanelEvent("onmouseover", buffHolder.onMouseOver );
	buffHolder.SetPanelEvent("onmouseout", buffHolder.onMouseOut );
	
	var completion = 360 * (1 - (Buffs.GetElapsedTime(heroID, buffID ) / (Buffs.GetDieTime(heroID, buffID ) - Buffs.GetCreationTime(heroID, buffID ))))
	buffBorder.style.clip = "radial(50% 50%, 0deg, " + completion + "deg)";
	var stacks = Buffs.GetStackCount(heroID, buffID )
	if(stacks > 0){
		var buffLabel =  $.CreatePanel( "Label", buff, "BuffLabel"+Buffs.GetName(heroID, buffID )+"Player"+id);
		buffLabel.AddClass("PlayerInfoModifierLabel")
		buffLabel.text = stacks
	}
}

function ToggleTeamInfo()
{
	var teamInfo = $("#GameHudTeamInfo")
	teamInfo.SetHasClass("TeamHidden", !(teamInfo.BHasClass("TeamHidden")) )
	$.Msg( $("#CloseImageID") )
	if(teamInfo.BHasClass("TeamHidden")){
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideRight.png")
	} else {
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
	}
}
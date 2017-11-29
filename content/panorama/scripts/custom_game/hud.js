"use strict";
var localID = Game.GetLocalPlayerID();

GameEvents.Subscribe("dota_player_update_query_unit", UpdateAbilityBar);
GameEvents.Subscribe("dota_player_update_selected_unit", UpdateAbilityBar);
GameEvents.Subscribe("dota_player_gained_level", UpdateAbilityBar);
GameEvents.Subscribe( "EndSkillSelection", UpdateAbilityBar);

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
	UpdateAbilityBar()
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
	UpdateMainContainer()
}

function UpdateAbilityBar()
{
	var currUnit = 	Players.GetLocalPlayerPortraitUnit()
	var localPlayerOwned = (currUnit == Players.GetPlayerHeroEntityIndex( localID ))
	var abilityBar = $("#MainSelectionAbilityContainer")
	var innate = $("#AbilityBarInnate")
	var currInnate = Abilities.GetAbilityName( Entities.GetAbility( currUnit, 3 ) )
	
	if( innate.abilityname != currInnate){
		innate.abilityname = currInnate
		innate.showTooltip = function(){
			$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", innate, innate.abilityname, Players.GetPlayerHeroEntityIndex( currUnit ));
		}
		innate.hideTooltip = function(){ 
			$.DispatchEvent("DOTAHideAbilityTooltip", innate);
		}
		
		innate.SetPanelEvent("onmouseover", innate.showTooltip );
		innate.SetPanelEvent("onmouseout", innate.hideTooltip );
	}
	
	if( Entities.IsHero( currUnit ) ){
		innate.style.visibility = "visible";
	} else {
		innate.style.visibility = "collapse";
	}
	for(var ability of abilityBar.Children()){
		if( ability.id != "AbilityBarInnate")
		{
			ability.style.visibility = "collapse";
			ability.DeleteAsync(0)
		}
		
	}
	for (var i = 0; i < Entities.GetAbilityCount( currUnit ); i++) {
		var abilityID = Entities.GetAbility( currUnit, i )
		var isTalent = (Abilities.GetAbilityType( abilityID ) & ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES) == ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES
		if (!Abilities.IsHidden(currUnit, abilityID) && !isTalent && !Abilities.IsPassive( abilityID ) && i != 3){
			CreateAbility(currUnit, abilityID, localPlayerOwned)
		}
	}
}

function CreateAbility(unitID, abilityID, localPlayerOwned)
{
	var abilityBar = $("#MainSelectionAbilityContainer")
	
	var ability = $.CreatePanel( "DOTAAbilityImage", abilityBar, "AbilityUnit"+unitID+"Ability"+abilityID);
	ability.AddClass("AbilityBarAbility")
	
	if(localPlayerOwned)
	{
		var abilityhotkey = $.CreatePanel( "Panel", ability, "AbilityHotkeyUnit"+unitID+"Ability"+abilityID);
		abilityhotkey.AddClass("AbilityHotkeyFlair")
		
		var abilityhotkeylabel = $.CreatePanel( "Label", abilityhotkey, "AbilityHotkeyLabelUnit"+unitID+"Ability"+abilityID);
		abilityhotkeylabel.AddClass("AbilityMiniLabel")
		abilityhotkeylabel.text = Abilities.GetKeybind(abilityID)
		
		
		var abilitylevel = $.CreatePanel( "Panel", ability, "AbilityLevelUnit"+unitID+"Ability"+abilityID);
		abilitylevel.AddClass("AbilityLevelFlair")
		if( Entities.GetAbilityPoints( unitID ) > 0 && 	Entities.GetLevel( unitID ) >= Abilities.GetHeroLevelRequiredToUpgrade( abilityID ) && Abilities.GetLevel( abilityID ) < Abilities.GetMaxLevel( abilityID ) )
		{
			var abilitycross = $.CreatePanel( "Image", abilitylevel, "AbilityLevelLabelUnit"+unitID+"Ability"+abilityID);
			abilitycross.AddClass("AbilityLevelImage")
			abilitycross.SetImage("file://{images}/custom_game/cross.png")
			abilitycross.hittest = false
			abilitylevel.upgradeAbility = function(){ 
				$.Msg("Leveled up")
				Abilities.AttemptToUpgrade( abilityID );
				UpdateAbilityBar()
			}
			
			abilitylevel.SetPanelEvent("onactivate", abilitylevel.upgradeAbility );
				
		} else {
			var abilitylevellabel = $.CreatePanel( "Label", abilitylevel, "AbilityLevelLabelUnit"+unitID+"Ability"+abilityID);
			abilitylevellabel.AddClass("AbilityMiniLabel")
			abilitylevellabel.text = Abilities.GetLevel( abilityID )
		}
	}
	
	ability.abilityname = Abilities.GetAbilityName( abilityID );
	ability.showTooltip = function(){
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", ability, ability.abilityname, Players.GetPlayerHeroEntityIndex( unitID ));
	}
	ability.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", ability);
	}
	
	ability.SetPanelEvent("onmouseover", ability.showTooltip );
	ability.SetPanelEvent("onmouseout", ability.hideTooltip );
}

function UpdateMainContainer()
{
	var currUnit = 	Players.GetLocalPlayerPortraitUnit()
	var portrait = $("#MainSelectionHeroPortrait")
	portrait.heroname = Entities.GetUnitName( currUnit )
	var healthBar = $("#MainSelectionHealthBar")
	var manaBar = $("#MainSelectionManaBar")
	var healthLabel = $("#HealthLabel")
	var healthRegenLabel = $("#HealthRegenLabel")
	var manaLabel = $("#ManaLabel")
	var manaRegenLabel = $("#ManaRegenLabel")
	
	healthBar.max = Entities.GetMaxHealth( currUnit )
	healthBar.value = Entities.GetHealth( currUnit )
	
	var stats = $("#HeroStatsContainer")
	if( Entities.IsHero( currUnit ) ){
		stats.style.visibility = "visible";
	} else {
		stats.style.visibility = "collapse";
	}

	healthLabel.text = Entities.GetHealth( currUnit ) + "/" + Entities.GetMaxHealth( currUnit )
	healthRegenLabel.text = "+" + Entities.GetHealthThinkRegen( currUnit ).toFixed(1)
	
	manaBar.max = Entities.GetMaxMana( currUnit )
	manaBar.value = Entities.GetMana( currUnit )
	manaLabel.text = Entities.GetMana( currUnit ) + "/" + Entities.GetMaxMana( currUnit )
	manaRegenLabel.text = "+" + Entities.GetManaThinkRegen( currUnit ).toFixed(1)
	
	var buffContainer = $("#MainSelectionBuffContainer");
	var debuffContainer = $("#MainSelectionDebuffContainer");
	for(var buff of buffContainer.Children()){	
		buff.style.visibility = "collapse";
		buff.DeleteAsync(0)
	}
	for(var buff of debuffContainer.Children()){	
		buff.style.visibility = "collapse";
		buff.DeleteAsync(0)
	}
	var buffCount = 0
	for (var i = 0; i < Entities.GetNumBuffs(currUnit); i++) {
		var buffID = Entities.GetBuff(currUnit, i)
		if (!Buffs.IsHidden(currUnit, buffID ) && buffCount <= 8){
			CreateMainBuff(currUnit, buffID)
			buffCount++
		}
	}
}

function CreateMainBuff(heroID, buffID)
{
	var buffContainer = $("#MainSelectionBuffContainer");
	var debuffContainer = $("#MainSelectionDebuffContainer");
	
	var parentPanel
	if(Buffs.IsDebuff(heroID, buffID) ){
		parentPanel = debuffContainer
	} else {
		parentPanel = buffContainer
	}
	var buffHolder = $.CreatePanel( "Panel", parentPanel, "BuffHolder"+Buffs.GetName(heroID, buffID )+"Main");
	buffHolder.AddClass("PlayerInfoModifierHolder")
	var buff = $.CreatePanel( "DOTAAbilityImage", buffHolder, "Buff"+Buffs.GetName(heroID, buffID )+"Main");
	buffHolder.heroID = heroID;
	buffHolder.buffID = buffID;
	
	var buffBorder =  $.CreatePanel( "Panel", buffHolder, "BuffBorder"+Buffs.GetName(heroID, buffID )+"Main");
	buff.AddClass("PlayerMainModifier")
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
		var buffLabel =  $.CreatePanel( "Label", buff, "BuffLabel"+Buffs.GetName(heroID, buffID )+"Main");
		buffLabel.AddClass("PlayerMainModifierLabel")
		buffLabel.text = stacks
	}
}

function UpdateInfoContainer(id)
{
	var playerPortrait =  $("#PlayerInfoPortraitPlayer"+id);
	var heroID = Players.GetPlayerHeroEntityIndex( id )
	if(heroID != null && playerPortrait != null){
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
				CreateInfoBuff(heroID, buffID, id)
			}
		}
	}
}

function CreateInfoBuff(heroID, buffID, id)
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
	if(teamInfo.BHasClass("TeamHidden")){
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideRight.png")
	} else {
		$("#CloseImageID").SetImage("file://{images}/custom_game/slideLeft.png")
	}
}
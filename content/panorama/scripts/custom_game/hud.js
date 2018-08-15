"use strict";
var localID = Game.GetLocalPlayerID();


GameEvents.Subscribe("dota_player_update_query_unit", UpdateSelectedUnit);
GameEvents.Subscribe("dota_player_update_selected_unit", UpdateSelectedUnit);
GameEvents.Subscribe("dota_player_gained_level", UpdateSelectedUnit);
GameEvents.Subscribe( "EndSkillSelection", UpdateSelectedUnit);
GameEvents.Subscribe( "EndSkillSelection", SetHud);
GameEvents.Subscribe( "raid_kings_open_inventory", OpenInventory);
GameEvents.Subscribe( "raid_kings_upgraded_equipment", UpdateInventory);

var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements");

(function(){
	// Fix DOTA buttons
	var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements");
	var abilityHud = dotaHud.FindChildTraverse("lower_hud");
	var netgraph = dotaHud.FindChildTraverse("NetGraph");
	var stats = dotaHud.FindChildTraverse("quickstats");
	var topbar = dotaHud.FindChildTraverse("topbar");
	var glyph = dotaHud.FindChildTraverse("GlyphScanContainer");
	var fancyMinimap = dotaHud.FindChildTraverse("HUDSkinMinimap");
	fancyMinimap.style.visibility = "collapse";
	abilityHud.style.visibility = "collapse";
	stats.style.visibility = "collapse";
	topbar.style.visibility = "collapse";
	glyph.style.visibility = "collapse";
	
	
	var skillSelectionDone = CustomNetTables.GetTableValue("skill_selection", "skillPickPhaseParams")
	if( (skillSelectionDone != null && skillSelectionDone["skillPickPhaseFinished"] && skillSelectionDone["skillPickPhaseFinished"] == 1) ){
		SetHud()
	}

	CreateTeamInfo()
	UpdateSelectedUnit()
	CreateOverheadButtons()
	InitializeTooltips()
})();

function InitializeTooltips()
{
	var localHero = Players.GetPlayerHeroEntityIndex( localID )
	var infoAD = $("#InfoAttackDamageContainer");
	infoAD.SetDialogVariable( "basedamage", Math.floor((Entities.GetDamageMin( localHero ) + Entities.GetDamageMax( localHero ))/2 + 0.5) );
	infoAD.SetDialogVariable( "bonusdamage", Entities.GetDamageBonus( localHero ));
	infoAD.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoAD, $.Localize( "#AttackDamageInfoTitle", infoAD), $.Localize( "#AttackDamageInfoText", infoAD))} );
	
	var infoAS = $("#InfoAttackSpeedContainer");
	infoAS.SetDialogVariable( "bat", Entities.GetBaseAttackTime( localHero ).toFixed(2) );
	infoAS.SetDialogVariable( "aps", Entities.GetAttacksPerSecond( localHero ).toFixed(2) );
	infoAS.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoAS, $.Localize( "#AttackSpeedInfoTitle", infoAS), $.Localize( "#AttackSpeedInfoText", infoAS))} );
	
	var infoAR = $("#InfoAttackRangeContainer");
	infoAR.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoAR, $.Localize( "#AttackRangeInfoTitle", infoAR), $.Localize( "#AttackRangeInfoText", infoAR))} );
	
	var infoMS = $("#InfoSpeedContainer");
	infoMS.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoMS, $.Localize( "#SpeedInfoTitle", infoMS), $.Localize( "#SpeedInfoText", infoMS))} );
	
	var infoDA = $("#InfoDamageAmpContainer");
	infoDA.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoDA, $.Localize( "#DamageAmpInfoTitle", infoDA), $.Localize( "#DamageAmpInfoText", infoDA))} );
	
	var infoPR = $("#InfoArmorContainer");
	var armor = Entities.GetPhysicalArmorValue( localHero )
	infoPR.SetDialogVariable( "resist",   ((0.05 * armor / (1 + 0.05 * Math.abs(armor))) * 100).toFixed(1) + "%" );
	infoPR.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoPR, $.Localize( "#ArmorInfoTitle", infoPR), $.Localize( "#ArmorInfoText", infoPR))} );
	
	var infoMR = $("#InfoMagicResistanceContainer");
	infoMR.SetDialogVariable( "resist",  (Entities.GetMagicalArmorValue( localHero ).toFixed(4) * 100).toFixed(1) + "%");
	infoMR.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoMR, $.Localize( "#MagicResistInfoTitle", infoMR), $.Localize( "#MagicResistInfoText", infoMR))} );
	
	var infoE = $("#InfoEvasionContainer");
	infoE.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoE, $.Localize( "#EvasionInfoTitle", infoE), $.Localize( "#EvasionInfoText", infoE))} );
	
	var infoSR = $("#InfoStatusResistanceContainer");
	infoSR.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoSR, $.Localize( "#StatusResistanceInfoTitle", infoSR), $.Localize( "#StatusResistanceInfoText", infoSR))} );
	
	var infoDR = $("#InfoDamageResistanceContainer");
	infoDR.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoDR, $.Localize( "#DamageResistanceInfoTitle", infoDR), $.Localize( "#DamageResistanceInfoText", infoDR))} );
	
	var infoSA = $("#InfoSpellAmpContainer");
	infoSA.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoSA, $.Localize( "#SpellAmpInfoTitle", infoSA), $.Localize( "#SpellAmpInfoText", infoSA))} );
	
	var infoCD = $("#InfoCooldownReductionContainer");
	infoCD.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoCD, $.Localize( "#CooldownReductionInfoTitle", infoCD), $.Localize( "#CooldownReductionInfoText", infoCD))} );
	
	var infoCR = $("#InfoCastRangeContainer");
	infoCR.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoCR, $.Localize( "#CastrangeBonusInfoTitle", infoCR), $.Localize( "#CastrangeBonusInfoText", infoCR))} );
	
	var infoStA = $("#InfoStatusAmpContainer");
	infoStA.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoStA, $.Localize( "#StatusAmpInfoTitle", infoStA), $.Localize( "#StatusAmpInfoText", infoStA))} );
	
	var infoHA = $("#InfoHealAmpContainer");
	infoHA.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoHA, $.Localize( "#HealAmpInfoTitle", infoHA), $.Localize( "#HealAmpInfoText", infoHA))} );
	
	var infoDV = $("#InfoDayVisionContainer");
	infoDV.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoDV, $.Localize( "#DayVisionInfoTitle", infoDV), $.Localize( "#DayVisionInfoText", infoDV))} );
	
	var infoNV = $("#InfoNightVisionContainer");
	infoNV.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoNV, $.Localize( "#NightVisionInfoTitle", infoNV), $.Localize( "#NightVisionInfoText", infoNV))} );
	
	var heroInfo = CustomNetTables.GetTableValue("hero_properties", Entities.GetUnitName( localHero ) + localHero)
	if(heroInfo != null){
		var infoSTR = $("#InfoStrengthContainer");
		infoSTR.SetDialogVariable( "armor", (heroInfo.strength * 0.07).toFixed(1) );
		infoSTR.SetDialogVariable( "mr", (heroInfo.strength * 0.1).toFixed(1) + "%");
		infoSTR.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoSTR, $.Localize( "#StrengthInfoTitle", infoSTR), $.Localize( "#StrengthInfoText", infoSTR))} );
		var infoAGI = $("#InfoAgilityContainer");
		infoAGI.SetDialogVariable( "ms", (heroInfo.agility * 0.072).toFixed(0) );
		infoAGI.SetDialogVariable( "as", (heroInfo.agility * 1).toFixed(0) );
		infoAGI.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoAGI, $.Localize( "#AgilityInfoTitle", infoAGI), $.Localize( "#AgilityInfoText", infoAGI))} );
		var infoINT = $("#InfoIntelligenceContainer");
		infoINT.SetDialogVariable( "amp", (heroInfo.intellect * 0.05).toFixed(1) + "%");
		infoINT.SetDialogVariable( "mana", (heroInfo.intellect * 12).toFixed(0) );
		infoINT.SetDialogVariable( "regen", (heroInfo.intellect * 0.08).toFixed(1) );
		infoINT.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoINT, $.Localize( "#IntellectInfoTitle", infoINT), $.Localize( "#IntellectInfoText", infoINT))} );
		var infoLUK = $("#InfoLuckContainer");
		infoLUK.SetDialogVariable( "evasion", (heroInfo.luck * 0.08).toFixed(1) + "%");
		infoLUK.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoLUK, $.Localize( "#LuckInfoTitle", infoLUK), $.Localize( "#LuckInfoText", infoLUK))} );
		var infoVIT = $("#InfoVitalityContainer");
		infoVIT.SetDialogVariable( "hp", (heroInfo.vitality * 20).toFixed(0));
		infoVIT.SetDialogVariable( "regen", (heroInfo.vitality * 0.2).toFixed(1));
		infoVIT.SetPanelEvent("onmouseover", function(){ShowTextTooltip(infoVIT, $.Localize( "#VitalityInfoTitle", infoVIT), $.Localize( "#VitalityInfoText", infoVIT))} );
	}
}

function CreateOverheadButtons()
{
	var overheadButtons = dotaHud.FindChildTraverse("MenuButtons").FindChildTraverse("ButtonBar");
	for(var btn of overheadButtons.Children()){
		if(btn.id == "EquipmentButton" || btn.id == "InfoButton")
		{
			btn.style.visibility = "collapse"
			btn.DeleteAsync(0)
		}
	}
	if($("#EquipmentButton") == null){
		var equipmentButton =  $.CreatePanel( "Button", $.GetContextPanel(), "EquipmentButton");
		equipmentButton.SetParent(overheadButtons)
		equipmentButton.AddClass("DOTAHudMenuButtons")
		equipmentButton.style.visibility = "visible";
		equipmentButton.style.backgroundImage = "url(\"file://{images}/custom_game/equipmentIcon.png\")";
		equipmentButton.SetPanelEvent("onactivate", QueryOpenInventory );
		$("#HeroInventoryPanel") .SetHasClass( "Hidden", true )
	}
	if($("#InfoButton") == null){
		var infoButton =  $.CreatePanel( "Button", $.GetContextPanel(), "InfoButton");
		infoButton.SetParent(overheadButtons)
		infoButton.AddClass("DOTAHudMenuButtons")
		infoButton.style.visibility = "visible";
		infoButton.style.backgroundImage = "url(\"file://{images}/custom_game/infoIcon.png\")";
		infoButton.SetPanelEvent("onactivate", OpenInfoHud );
	}
	
	$("#HeroInformationContainer").SetHasClass( "Hidden", true )
}

function QueryOpenInventory()
{
	GameEvents.SendCustomGameEventToServer( "QueryCurrentEquipment" + localID, {} )
}

var DOTA_TO_RAID_KING_TABLE = {	"npc_dota_hero_invoker":"primordial",
								"npc_dota_hero_visage": "archon",
								"npc_dota_hero_windrunner":"sylph",
								"npc_dota_hero_necrolyte":"puppeteer",
								"npc_dota_hero_phantom_assassin":"shinigami",
								"npc_dota_hero_lina":"ifrit",
								"npc_dota_hero_legion_commander":"gladiatrix",
								"npc_dota_hero_omniknight":"justicar",
								"npc_dota_hero_sven":"guardian",
								"npc_dota_hero_dazzle":"mystic",
								"npc_dota_hero_treant":"forest",
								"npc_dota_hero_skeleton_king":"wraith",
								"npc_dota_hero_lone_druid":"shifter",
								"npc_dota_hero_templar_assassin":"peacekeeper",
								"npc_dota_hero_kunkka":"buccaneer",
								"npc_dota_hero_tusk":"brawler",
								"npc_dota_hero_nevermore":"collector",
								"npc_dota_hero_shadow_demon":"revenant",
								"npc_dota_hero_crystal_maiden":"avalanche"}

function OpenInventory(args)
{
	var inventory = $("#HeroInventoryPanel") 
	inventory.SetHasClass( "Hidden", !inventory.BHasClass("Hidden") )
	$.Msg("hello?")
	UpdateInventory(args)
}

function UpdateInventory(args)
{
	var localHero = Players.GetPlayerHeroEntityIndex( localID )
	var heroName = DOTA_TO_RAID_KING_TABLE[Players.GetPlayerSelectedHero( localID )]

	for(var i = 1; i <= 5; i++){
		(function(args, i){
			var weapon = $("#WeaponUpgrade" + i);
			weapon.SetHasClass("CurrentUpgrade", args.weapon == i);
			
			if( args.weapon + 1 == i && args.weapon + 1 <= 5 ){
				weapon.SetPanelEvent("onactivate", function(){ GameEvents.SendCustomGameEventToServer( "TryUpgradeWeapon" + localID, {} ) } );
			} else {
				weapon.SetPanelEvent("onactivate", function(){} );
			}
			weapon.SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideAbilityTooltip", weapon); } );
			weapon.SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", weapon, "item_" + heroName + "_weapon_" + i, localHero); } );
		})(args, i);
		
		(function(args, i){
			var armor = $("#ArmorUpgrade" + i);
			armor.SetHasClass("CurrentUpgrade", args.armor == i);
			if( args.armor + 1 == i && args.armor + 1 <= 5 ){
				armor.SetPanelEvent("onactivate", function(){ GameEvents.SendCustomGameEventToServer( "TryUpgradeArmor" + localID, {} ) } );
			} else {
				armor.SetPanelEvent("onactivate", function(){} );
			}
			
			armor.SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideAbilityTooltip", armor); } );
			armor.SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", armor, "item_" + heroName + "_armor_" + i, localHero); } );
		})(args, i);
		
		(function(args, i){
			var other = $("#OtherUpgrade" + i);
			other.SetHasClass("CurrentUpgrade", args.other == i);
			
			if( args.other + 1 == i && args.other + 1 <= 5 ){
				other.SetPanelEvent("onactivate", function(){ GameEvents.SendCustomGameEventToServer( "TryUpgradeOther" + localID, {} ) } );
			} else {
				other.SetPanelEvent("onactivate", function(){} );
			}
			
			other.SetPanelEvent("onmouseout", function(){ $.DispatchEvent("DOTAHideAbilityTooltip", other); } );
			other.SetPanelEvent("onmouseover", function(){ $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", other, "item_" + heroName + "_other_" + i, localHero); } );
		})(args, i);
	}
}

function OpenInfoHud()
{
	var heroInfo = $("#HeroInformationContainer") 
	var portrait = $("#PlayerHeroInfoModelContainer")
	if(!$("#PlayerHeroInfoModel")){
		portrait.BCreateChildren("<DOTAScenePanel id='PlayerHeroInfoModel' unit='"+ Entities.GetUnitName( Players.GetPlayerHeroEntityIndex( localID ) ) +"' environment='camera1' particleonly='false' antialias='true'/>");
	}
	$("#PlayerHeroInfoModel").AddClass("HeroInfoScenePanel")
	heroInfo.SetHasClass( "Hidden", !$("#HeroInformationContainer").BHasClass("Hidden") )
	UpdateInfoHud()
	InitializeTooltips()
}

function UpdateInfoHud()
{
	var localHero = Players.GetPlayerHeroEntityIndex( localID )
	var heroInfo = CustomNetTables.GetTableValue("hero_properties", Entities.GetUnitName( localHero ) + localHero)
	$("#InfoAttackDamageLabel").text = Math.floor((Entities.GetDamageMin( localHero ) + Entities.GetDamageMax( localHero ))/2 + 0.5)
	if (Entities.GetDamageBonus( localHero ) > 0){ $("#InfoAttackDamageLabel").text = Math.floor((Entities.GetDamageMin( localHero ) + Entities.GetDamageMax( localHero ))/2 + 0.5) + Entities.GetDamageBonus( localHero )}
	$("#InfoAttackSpeedLabel").text = Math.floor(Entities.GetAttackSpeed( localHero ).toFixed(2) * 100)
	$("#InfoAttackRangeLabel").text = Entities.GetAttackRange( localHero )
	$("#InfoDamageAmpLabel").text = heroInfo.damageamp.toFixed(1) + "%"
	$("#InfoArmorLabel").text = Entities.GetPhysicalArmorValue( localHero ).toFixed(1)
	$("#InfoMagicResistanceLabel").text = (Entities.GetMagicalArmorValue( localHero ).toFixed(4) * 100).toFixed(1) + "%"
	$("#InfoEvasionLabel").text = (heroInfo.evasion * 100).toFixed(1) + "%"
	$("#InfoStatusResistanceLabel").text = heroInfo.statusresistance.toFixed(1) + "%"
	$("#InfoDamageResistanceLabel").text = ( -heroInfo.damageresistance.toFixed(1) ) + "%"
	$("#InfoSpellAmpLabel").text = heroInfo.spellamp.toFixed(1) + "%"
	$("#InfoCooldownReductionLabel").text = heroInfo.cdr.toFixed(1) + "%"
	$("#InfoCastRangeLabel").text = heroInfo.castrange.toFixed(0)
	$("#InfoStatusAmpLabel").text = heroInfo.statusamp.toFixed(1) + "%"
	$("#InfoHealAmpLabel").text = heroInfo.healamp.toFixed(1) + "%"
	$("#InfoDayVisionLabel").text = Entities.GetDayTimeVisionRange( localHero )
	$("#InfoNightVisionLabel").text = Entities.GetNightTimeVisionRange( localHero )
	$("#InfoSpeedLabel").text = Entities.GetIdealSpeed( localHero ).toFixed(0)
	$("#InfoStrengthLabel").text = heroInfo.strength
	$("#InfoAgilityLabel").text = heroInfo.agility
	$("#InfoIntelligenceLabel").text = heroInfo.intellect
	$("#InfoLuckLabel").text = heroInfo.luck
	$("#InfoVitalityLabel").text = heroInfo.vitality
	if(!$("#HeroInformationContainer").BHasClass("Hidden")){
		$.Schedule(0.1, UpdateInfoHud);
	}
}

function SetHud()
{
	var minimapCont = dotaHud.FindChildTraverse("minimap_container");
	minimapCont.style.align = "right top";
	dotaHud.FindChildTraverse("minimap_block").style.align = "right top";
	dotaHud.FindChildTraverse("minimap").style.align = "right top";
	
	dotaHud.FindChildTraverse("minimap_block").style.marginRight = "10px";
	minimapCont.style.marginTop = "50px";
	dotaHud.FindChildTraverse("minimap_block").style.borderRadius = "50%";
}

function CreateTeamInfo(){
	var playerCount = Game.GetAllPlayerIDs();
	if(playerCount.length > 1){
		for (var pID of playerCount){
			if(pID != localID){CreateInfoContainer(pID);}
		}
	} else {
		$("#GameHudTeamInfo").AddClass("Hidden")
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
	var scoreboard = dotaHud.FindChildTraverse("scoreboard");
	if( scoreboard.BHasClass("ScoreboardClosed") ){
		$("#GameHudTeamInfo").style.visibility = "visible"
	} else{ $("#GameHudTeamInfo").style.visibility = "collapse" }
	for (var pID of playerCount){
		if(pID != localID){UpdateInfoContainer(pID);}
	}
	UpdateMainContainer()
	UpdateAbilityBar()
}

function UpdateAbilityBar()
{
	var currUnit = 	Players.GetLocalPlayerPortraitUnit()
	var abilityBar = $("#MainSelectionAbilityContainer")
	for(var abilityHolder of abilityBar.Children()){
		if( abilityHolder.id != "AbilityBarInnate" && abilityHolder.abilityname != Abilities.GetAbilityName( Entities.GetAbility( currUnit, 3 ) ))
		{
			var abilityID = abilityHolder.abilityID
			
			var onCooldown =  Abilities.GetCooldownTimeRemaining( abilityID ) > 0
			var isActivated = Abilities.IsActivated( abilityID )
			abilityHolder.ability.SetHasClass("AbilityDisabled", onCooldown || !isActivated)
			abilityHolder.toggleState.SetHasClass("AbilityToggledOn", Abilities.GetToggleState( abilityID ))
			if( abilityID != null && onCooldown && isActivated) {
				abilityHolder.cooldownPanel.style.visibility = "visible"
				abilityHolder.cooldownPanelLabel.style.visibility = "visible"
				abilityHolder.cooldownPanelLabel.text = Abilities.GetCooldownTimeRemaining( abilityID ).toFixed(1)
				var completion = Abilities.GetCooldownTimeRemaining( abilityID ) /  Abilities.GetCooldownLength( abilityID ) * 360
				abilityHolder.cooldownPanel.style.clip = "radial(50% 50%, 0deg, " + Math.floor(completion) + "deg)";
			} else{
				abilityHolder.cooldownPanel.style.visibility = "collapse"
				abilityHolder.cooldownPanelLabel.style.visibility = "collapse"
			}
			
			if( Abilities.GetManaCost( abilityID ) > 0)
			{
				abilityHolder.manaPanel.style.visibility = "visible"
			}
			if(abilityHolder.manaLabel && abilityHolder.levelPanel)
			{
				abilityHolder.manaLabel.text = Abilities.GetManaCost( abilityID );
				abilityHolder.levelPanel.text = Abilities.GetLevel( abilityID );
			}
			
		}
	}
}

function ShowTextTooltip(panel, title, text)
{
	$.DispatchEvent("DOTAShowTitleTextTooltip", panel, title, text);
}

function UpdateSelectedUnit()
{
	var currUnit = 	Players.GetLocalPlayerPortraitUnit()
	var localPlayerOwned = (currUnit == Players.GetPlayerHeroEntityIndex( localID ))
	var portrait = $("#MainSelectionHeroPortrait")
	
	var level = $("#MainSelectionLevelContainerLabel")
	level.text = Entities.GetLevel( currUnit )
	
	var abilityBar = $("#MainSelectionAbilityContainer")
	var innate = $("#AbilityBarInnate")
	var currInnate = Abilities.GetAbilityName( Entities.GetAbility( currUnit, 3 ) )
	
	if( portrait.unitID != currUnit || innate.abilityname != currInnate ){
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
	
	portrait.unitID = currUnit
	portrait.SetUnit(Entities.GetUnitName( currUnit ), "default")
	
	
	
	if( Entities.IsHero( currUnit ) ){
		innate.style.visibility = "visible";
	} else {
		innate.style.visibility = "collapse";
	}
	
	for(var ability of abilityBar.Children()){
		if( ability.id != "AbilityBarInnate" && ability.abilityname != Abilities.GetAbilityName( Entities.GetAbility( currUnit, 3 ) ))
		{
			ability.style.visibility = "collapse";
			ability.DeleteAsync(0)
		}
		
	}
	for (var i = 0; i < Entities.GetAbilityCount( currUnit ); i++) {
		var abilityID = Entities.GetAbility( currUnit, i )
		var isTalent = (Abilities.GetAbilityType( abilityID ) & ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES) == ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES
		var isHidden = (Abilities.GetBehavior( abilityID ) & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_HIDDEN) == DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_HIDDEN
		if (!Abilities.IsHidden(currUnit, abilityID) && !isHidden && !isTalent && i != 3){
			CreateAbility(currUnit, abilityID, localPlayerOwned)
		}
	}
}

function CreateAbility(unitID, abilityID, localPlayerOwned)
{
	var abilityBar = $("#MainSelectionAbilityContainer")
	
	var abilityHolder = $.CreatePanel( "Panel", abilityBar, "AbilityHolderUnit"+unitID+"Ability"+abilityID);
	abilityHolder.abilityID = abilityID
	abilityHolder.AddClass("AbilityBarAbilityContainer");
	
	var ability = $.CreatePanel( "DOTAAbilityImage", abilityHolder, "AbilityUnit"+unitID+"Ability"+abilityID);
	ability.AddClass("AbilityBarAbility");
	abilityHolder.ability = ability

	ability.abilityname = Abilities.GetAbilityName( abilityID );
	
	var toggleState = $.CreatePanel( "Panel", abilityHolder, "AbilityUnit"+unitID+"Ability"+abilityID);
	toggleState.AddClass("AbilityBarToggle");
	abilityHolder.toggleState = toggleState
	abilityHolder.toggleState.SetHasClass("AbilityToggledOn", Abilities.GetToggleState( abilityID ))
	
	var abilityCooldown = $.CreatePanel( "Panel", abilityHolder, "AbilityUnitCooldown"+unitID+"Ability"+abilityID);
	abilityCooldown.AddClass("AbilityBarCooldown")
	abilityHolder.cooldownPanel = abilityCooldown
	
	var abilityCooldownLabel = $.CreatePanel( "Label", abilityHolder, "AbilityUnitCDLabel"+unitID+"Ability"+abilityID);
	abilityCooldownLabel.AddClass("AbilityBarCooldownLabel")
	abilityHolder.cooldownPanelLabel = abilityCooldownLabel
	
	if( Abilities.GetCooldownTimeRemaining( abilityHolder.abilityID ) > 0) {
		abilityCooldownLabel.text = Abilities.GetCooldownTimeRemaining( abilityID )
		var completion = Abilities.GetCooldownTimeRemaining( abilityHolder.abilityID ) /  Abilities.GetCooldownLength( abilityID )
		abilityCooldown.style.clip = "radial(50% 50%, 0deg, " + Math.floor(completion) + "deg)";
	} else{
		abilityCooldown.style.visibility = "collapse"
		abilityCooldownLabel.style.visibility = "collapse"
	}
	
	if(Entities.GetTeamNumber( unitID ) == Entities.GetTeamNumber( Players.GetPlayerHeroEntityIndex( localID ) ))
	{
		var abilitylevel = $.CreatePanel( "Panel", abilityHolder, "AbilityLevelUnit"+unitID+"Ability"+abilityID);
		abilitylevel.AddClass("AbilityLevelFlair")
		abilityHolder.levelPanel = abilitylevel
		
		var abilitylevellabel = $.CreatePanel( "Label", abilitylevel, "AbilityLevelLabelUnit"+unitID+"Ability"+abilityID);
		abilitylevellabel.AddClass("AbilityMiniLabel")
		abilitylevellabel.text = Abilities.GetLevel( abilityID )
		abilitylevellabel.style.zIndex = 5
		
		if(localPlayerOwned)
		{
			var abilityhotkey = $.CreatePanel( "Panel", abilityHolder, "AbilityHotkeyUnit"+unitID+"Ability"+abilityID);
			abilityhotkey.AddClass("AbilityHotkeyFlair")
			
			var abilityhotkeylabel = $.CreatePanel( "Label", abilityhotkey, "AbilityHotkeyLabelUnit"+unitID+"Ability"+abilityID);
			abilityhotkeylabel.AddClass("AbilityMiniLabel")
			abilityhotkeylabel.text = Abilities.GetKeybind(abilityID)
			
			if( Entities.GetAbilityPoints( unitID ) > 0 && 	Entities.GetLevel( unitID ) >= Abilities.GetHeroLevelRequiredToUpgrade( abilityID ) && Abilities.GetLevel( abilityID ) < Abilities.GetMaxLevel( abilityID ) )
			{
				abilitylevel.AddClass("AbilityCanBeLeveled")
				abilitylevel.upgradeAbility = function(){ 
					Abilities.AttemptToUpgrade( abilityID );
					$.Schedule(0.03, function() { UpdateSelectedUnit() })
				}
				
				abilitylevel.SetPanelEvent("onactivate", abilitylevel.upgradeAbility );
					
			} 
		}
		
		var abilityresource = $.CreatePanel( "Panel", ability, "AbilityResourceCostUnit"+unitID+"Ability"+abilityID);
		abilityresource.AddClass("AbilityResourceFlair");
		abilityresource.style.backgroundColor = "#49AAE4CC"
		abilityHolder.manaPanel = abilityresource
		
		var abilityresourcelabel = $.CreatePanel( "Label", abilityresource, "AbilityResourceCostLabelUnit"+unitID+"Ability"+abilityID);
		abilityresourcelabel.AddClass("AbilityResourceLabel");
		abilityresourcelabel.text = Abilities.GetManaCost( abilityID );
		abilityresourcelabel.style.color = "#FFFFFF"
		abilityHolder.manaLabel = abilityresourcelabel
		
		if( Abilities.GetManaCost( abilityID ) == 0)
		{
			abilityresource.style.visibility = "collapse"
		}
	}
	
	abilityHolder.showTooltip = function(){
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", abilityHolder, ability.abilityname, unitID);
	}
	abilityHolder.hideTooltip = function(){ 
		$.DispatchEvent("DOTAHideAbilityTooltip", abilityHolder);
	}
	
	abilityHolder.tryCast = function(){ 
		Abilities.ExecuteAbility( abilityID, Abilities.GetCaster( abilityID ), false )
	}
	
	abilityHolder.SetPanelEvent("onmouseover", abilityHolder.showTooltip );
	abilityHolder.SetPanelEvent("onmouseout", abilityHolder.hideTooltip );
	abilityHolder.SetPanelEvent("onactivate", abilityHolder.tryCast );
}

function SetLocalCameraTarget()
{
	GameUI.SetCameraTarget( Players.GetLocalPlayerPortraitUnit() )
	$.Schedule(0.03, function() { GameUI.SetCameraTarget( -1 ) });
}

function UpdateMainContainer()
{
	var currUnit = 	Players.GetLocalPlayerPortraitUnit()
	var healthBar = $("#MainSelectionHealthBar")
	var healthBarHeal = $("#MainSelectionHealthBarHeal")
	var manaBar = $("#MainSelectionManaBar")
	var healthLabel = $("#HealthLabel")
	var healthRegenLabel = $("#HealthRegenLabel")
	var manaLabel = $("#ManaLabel")
	var manaRegenLabel = $("#ManaRegenLabel")
	
	var stats = $("#HeroStatsContainer")
	
	var damage = $("#StatsDamageLabel")
	damage.text = Math.floor((Entities.GetDamageMin( currUnit ) + Entities.GetDamageMax( currUnit ))/2 + 0.5)
	if (Entities.GetDamageBonus( currUnit ) > 0){ damage.text = damage.text + " + " + Entities.GetDamageBonus( currUnit )}
	var armor = $("#StatsArmorLabel")
	armor.text = Entities.GetPhysicalArmorValue( currUnit ).toFixed(0)
	var speed = $("#StatsSpeedLabel")
	speed.text = Entities.GetIdealSpeed( currUnit ).toFixed(0)
	if( Entities.IsHero( currUnit ) ){
		var heroInfo = CustomNetTables.GetTableValue("hero_properties", Entities.GetUnitName( currUnit ) + currUnit)
		if(heroInfo){
			stats.style.visibility = "visible";
			var strength = $("#StatsStrengthLabel")
			strength.text = heroInfo.strength.toFixed(0)
			var agility = $("#StatsAgilityLabel")
			agility.text = heroInfo.agility.toFixed(0)
			var intelligence = $("#StatsIntelligenceLabel")
			intelligence.text = heroInfo.intellect.toFixed(0)
			var vitality = $("#StatsVitalityLabel")
			vitality.text = heroInfo.vitality.toFixed(0)
			var luck = $("#StatsLuckLabel")
			luck.text = heroInfo.luck.toFixed(0)
			
			var hpBalance = heroInfo.dot - heroInfo.hot + Entities.GetHealthThinkRegen( currUnit ).toFixed(1)
			var hpbar1Perc = Entities.GetHealth( currUnit ) / Entities.GetMaxHealth( currUnit ) * 100
			healthBar.max = Entities.GetHealth( currUnit )
			healthBar.value = healthBar.max - Math.min(0, hpBalance)
			healthBar.style.width = hpbar1Perc + "%"
			
			
			var hpbar2Perc = 100 - hpbar1Perc
			healthBarHeal.max = Entities.GetMaxHealth( currUnit ) - Entities.GetHealth( currUnit )
			healthBarHeal.value = Math.abs( Math.min( 0, hpBalance) )
			healthBarHeal.style.width = hpbar2Perc + "%"
		}
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
		var hpPerc = Entities.GetHealth( heroID ) / Entities.GetMaxHealth( heroID ) * 100
		healthBarLabel.text = hpPerc.toFixed(1)+"%"
		
		
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
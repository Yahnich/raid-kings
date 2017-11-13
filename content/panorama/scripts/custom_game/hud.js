"use strict";
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
})();
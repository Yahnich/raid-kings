ItemManager = class({})

ItemTypes = {
["ITEM_TYPE_WEAPON"] = 1,
["ITEM_TYPE_ARMOR"] = 2,
["ITEM_TYPE_OTHER"] = 3,
["ITEM_TYPE_TRINKET"] = 4,
["ITEM_TYPE_RELIC"] = 5,
}

function ItemManager:constructor(owner, itemTable)
	self.owner = owner
	self.owner.ItemManagerEntity = self
	self.currentArmor = 0
	self.currentWeapon = 0
	self.currentOther = 0
	self.itemTable = itemTable
	self.armorTable = {}
	self.weaponTable = {}
	self.otherTable = {}
	
	self.owner.GetItemManager = function() return self.owner.ItemManagerEntity  end
	
	for itemType, items in pairs(itemTable) do -- stupid tonumber shit
		if itemType == "Armor" then
			for level, item in pairs(items) do
				self.armorTable[tonumber(level)] = item
			end
		elseif itemType == "Weapon" then
			for level, item in pairs(items) do
				self.weaponTable[tonumber(level)] = item
			end
		elseif itemType == "Other" then
			for level, item in pairs(items) do
				self.otherTable[tonumber(level)] = item
			end
		end
	end
	
	-- initialize items
	self:UpgradeArmor()
	self:UpgradeOther()
	self:UpgradeWeapon()
	
	self:InitWearables(owner)
	
	self.trinketTable = {}
	self.relicTable = {}
	
	self.weaponUpgradeListener = CustomGameEventManager:RegisterListener('TryUpgradeWeapon'..self.owner:GetPlayerID(), Context_Wrap( self, 'UpgradeWeapon'))
	self.armorUpgradeListener = CustomGameEventManager:RegisterListener('TryUpgradeArmor'..self.owner:GetPlayerID(), Context_Wrap( self, 'UpgradeArmor'))
	self.otherUpgradeListener = CustomGameEventManager:RegisterListener('TryUpgradeOther'..self.owner:GetPlayerID(), Context_Wrap( self, 'UpgradeOther'))
	
	self.equipmentQueryListener = CustomGameEventManager:RegisterListener('QueryCurrentEquipment'..self.owner:GetPlayerID(), Context_Wrap( self, 'QueryCurrentEquipment'))
end

function ItemManager:QueryCurrentEquipment()
	CustomGameEventManager:Send_ServerToPlayer(self.owner:GetPlayerOwner(), "raid_kings_open_inventory", {	weapon = self:GetWeaponLevel(), 
																											armor = self:GetArmorLevel(), 
																											other = self:GetOtherLevel() })
end

function ItemManager:InitWearables(hero)
	if GameRules.UnitKV[hero:GetName()]["AttachWearables"] then
		local wearables = GameRules.UnitKV[hero:GetName()]["AttachWearables"]
		self.baseWearables = {}
		for _, wearable in pairs( wearables ) do
			if type(wearable) == "string" then
				if string.match(wearable, "vmdl") then
					local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model=wearable}):FollowEntity(hero, true)
					table.insert(self.baseWearables, newWearable)
				elseif string.match(wearable, "vpcf") then
					local wearableFX = ParticleManager:CreateParticle(wearable, PATTACH_POINT_FOLLOW , hero)
					if GameRules.CosmeticsList[wearable] and GameRules.CosmeticsList[wearable].control_points then
						for cp, attachtype in pairs(GameRules.CosmeticsList[wearable].control_points) do
							ParticleManager:SetParticleControlEnt(wearableFX, tonumber(cp), hero, PATTACH_POINT_FOLLOW, attachtype, hero:GetAbsOrigin(), true)
						end
					end
					ParticleManager:ReleaseParticleIndex(wearableFX)
				end
			end
		end
	end
end

function ItemManager:GetOwner()
	return self.owner
end

function ItemManager:GetEquippedArmor()
	return self.equippedArmor
end

function ItemManager:GetArmorLevel()
	return self.currentArmor or 0
end

function ItemManager:UpgradeArmor()
	if self.currentArmor < #self.armorTable then
		if self:GetEquippedArmor() then
			self:GetOwner():RemoveItem( self.armorTable[self:GetEquippedArmor()] )
		end
		self.currentArmor = self.currentArmor + 1
		local armor = CreateItem(self.armorTable[self.currentArmor], nil, nil)
		self.equippedArmor = self:GetOwner():AddItem( armor )
		self:GetOwner():SetArmorWearables( self.equippedArmor:GetWearables() )
		
		CustomGameEventManager:Send_ServerToPlayer(self.owner:GetPlayerOwner(), "raid_kings_upgraded_equipment", {	weapon = self:GetWeaponLevel(), 
																													armor = self:GetArmorLevel(), 
																													other = self:GetOtherLevel() })
	else
		return error("Armor is maxed")
	end
end

function CDOTA_BaseNPC_Hero:SetArmorWearables( wearableTable )
	if self.armorWearableList then
		for _,wearable in ipairs(self.armorWearableList) do
			UTIL_Remove(wearable)
		end
	end
	self.armorWearableList = {}
	for _,v in pairs(wearableTable) do
		if type(v) == "string" then
			if string.match(v, "vmdl") then
				local newWearable = CreateUnitByName("wearable_dummy", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NOTEAM)
				newWearable:SetOriginalModel(v)
				newWearable:SetModel(v)
				newWearable:FollowEntity(self, true)
				newWearable:AddNewModifier(self, nil, "modifier_wearable", {})
				if GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particles then
					for _, wearableFX in pairs( GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particles ) do
						local wFX = ParticleManager:CreateParticle(wearableFX, PATTACH_ABSORIGIN_FOLLOW, newWearable)
						if GameRules.CosmeticsList[wearableFX] and GameRules.CosmeticsList[wearableFX].control_points then
							for cp, attachtype in pairs(GameRules.CosmeticsList[wearableFX].control_points) do
								ParticleManager:SetParticleControlEnt(wFX, tonumber(cp), newWearable, PATTACH_POINT_FOLLOW, attachtype, newWearable:GetAbsOrigin(), true)
							end
						end
						ParticleManager:ReleaseParticleIndex(wFX)
					end
				end
				if GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particle_levelup then
					local fxName = GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particle_levelup[tostring( self:GetItemManager():GetArmorLevel() )]
					local wFX = ParticleManager:CreateParticle(fxName, PATTACH_POINT_FOLLOW , newWearable)
					if GameRules.CosmeticsList[wearableFX] and GameRules.CosmeticsList[wearableFX].control_points then
						for cp, attachtype in pairs(GameRules.CosmeticsList[wearableFX].control_points) do
							ParticleManager:SetParticleControlEnt(wFX, tonumber(cp), newWearable, PATTACH_POINT_FOLLOW, attachtype, newWearable:GetAbsOrigin(), true)
						end
					end
					ParticleManager:ReleaseParticleIndex(wFX)
				end
				table.insert(self.armorWearableList, newWearable)
			elseif string.match(wearable, "vpcf") then
				local wearableFX = ParticleManager:CreateParticle(wearable, PATTACH_POINT_FOLLOW , hero)
				if GameRules.CosmeticsList[wearable] and GameRules.CosmeticsList[wearable].control_points then
					for cp, attachtype in pairs(GameRules.CosmeticsList[wearable].control_points) do
						ParticleManager:SetParticleControlEnt(wearableFX, tonumber(cp), hero, PATTACH_POINT_FOLLOW, attachtype, hero:GetAbsOrigin(), true)
					end
				end
				ParticleManager:ReleaseParticleIndex(wearableFX)
			end
		end
    end
end

function ItemManager:GetEquippedWeapon()
	return self.equippedWeapon
end

function ItemManager:GetWeaponLevel()
	return self.currentWeapon or 0
end

function ItemManager:UpgradeWeapon()
	if self.currentWeapon < #self.weaponTable then
		if self:GetEquippedWeapon() then
			self:GetOwner():RemoveItem(self.weaponTable[self:GetEquippedWeapon()] )
		end
		self.currentWeapon = self.currentWeapon + 1
		
		local weapon = CreateItem(self.weaponTable[self.currentWeapon], nil, nil)
		self.equippedWeapon = self:GetOwner():AddItem( weapon )
		self:GetOwner():SetWeaponWearables( weapon:GetWearables() )
		
		CustomGameEventManager:Send_ServerToPlayer(self.owner:GetPlayerOwner(), "raid_kings_upgraded_equipment", {	weapon = self:GetWeaponLevel(), 
																													armor = self:GetArmorLevel(), 
																													other = self:GetOtherLevel() })
	else
		return error("Weapon is maxed")
	end
end

function CDOTA_BaseNPC_Hero:SetWeaponWearables( wearableTable )
	if self.weaponWearableList then
		for _,wearable in ipairs(self.weaponWearableList) do
			UTIL_Remove(wearable)
		end
	end
	self.weaponWearableList = {}
	for _,v in pairs(wearableTable) do
		if type(v) == "string" then
			if string.match(v, "vmdl") then
				local newWearable = CreateUnitByName("wearable_dummy", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NOTEAM)
				newWearable:SetOriginalModel(v)
				newWearable:SetModel(v)
				newWearable:FollowEntity(self, true)
				newWearable:AddNewModifier(self, nil, "modifier_wearable", {})
				if GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particles then
					for _, wearableFX in pairs( GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particles ) do
						local wFX = ParticleManager:CreateParticle(wearableFX, PATTACH_ABSORIGIN_FOLLOW, newWearable)
						if GameRules.CosmeticsList[wearableFX] and GameRules.CosmeticsList[wearableFX].control_points then
							for cp, attachtype in pairs(GameRules.CosmeticsList[wearableFX].control_points) do
								ParticleManager:SetParticleControlEnt(wFX, tonumber(cp), newWearable, PATTACH_POINT_FOLLOW, attachtype, newWearable:GetAbsOrigin(), true)
							end
						end
						ParticleManager:ReleaseParticleIndex(wFX)
					end
				end
				if GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particle_levelup then
					local fxName = GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particle_levelup[tostring( self:GetItemManager():GetWeaponLevel() )]
					local wFX = ParticleManager:CreateParticle(fxName, PATTACH_POINT_FOLLOW , newWearable)
					if GameRules.CosmeticsList[wearableFX] and GameRules.CosmeticsList[wearableFX].control_points then
						for cp, attachtype in pairs(GameRules.CosmeticsList[wearableFX].control_points) do
							ParticleManager:SetParticleControlEnt(wFX, tonumber(cp), newWearable, PATTACH_POINT_FOLLOW, attachtype, newWearable:GetAbsOrigin(), true)
						end
					end
					ParticleManager:ReleaseParticleIndex(wFX)
				end
				table.insert(self.weaponWearableList, newWearable)
			elseif string.match(wearable, "vpcf") then
				local wearableFX = ParticleManager:CreateParticle(wearable, PATTACH_POINT_FOLLOW , hero)
				if GameRules.CosmeticsList[wearable] and GameRules.CosmeticsList[wearable].control_points then
					for cp, attachtype in pairs(GameRules.CosmeticsList[wearable].control_points) do
						ParticleManager:SetParticleControlEnt(wearableFX, tonumber(cp), hero, PATTACH_POINT_FOLLOW, attachtype, hero:GetAbsOrigin(), true)
					end
				end
				ParticleManager:ReleaseParticleIndex(wearableFX)
			end
		end
    end
end

function ItemManager:GetEquippedOther()
	return self.equippedOther
end

function ItemManager:GetOtherLevel()
	return self.currentOther or 0
end

function ItemManager:UpgradeOther()
	if self.currentOther < #self.otherTable then
		if self:GetEquippedOther() then
			self:GetOwner():RemoveItem(self.otherTable[self:GetEquippedOther()] )
		end
		self.currentOther = self.currentOther + 1
		local other = CreateItem(self.otherTable[self.currentOther], nil, nil)
		self.equippedOther = self:GetOwner():AddItem( other )
		self:GetOwner():SetOtherWearables( self.equippedOther:GetWearables() )
		
		CustomGameEventManager:Send_ServerToPlayer(self.owner:GetPlayerOwner(), "raid_kings_upgraded_equipment", {	weapon = self:GetWeaponLevel(), 
																													armor = self:GetArmorLevel(), 
																													other = self:GetOtherLevel() })
	else
		return error("Other is maxed")
	end
end

function CDOTA_BaseNPC_Hero:SetOtherWearables( wearableTable )
	if self.otherWearableList then
		for _,wearable in ipairs(self.otherWearableList) do
			UTIL_Remove(wearable)
		end
	end
	self.otherWearableList = {}
	for _,v in pairs(wearableTable) do
		if type(v) == "string" then
			if string.match(v, "vmdl") then
				local newWearable = CreateUnitByName("wearable_dummy", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NOTEAM)
				newWearable:SetOriginalModel(v)
				newWearable:SetModel(v)
				newWearable:FollowEntity(self, true)
				newWearable:AddNewModifier(self, nil, "modifier_wearable", {})
				if GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particles then
					for _, wearableFX in pairs( GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particles ) do
						local wFX = ParticleManager:CreateParticle(wearableFX, PATTACH_ABSORIGIN_FOLLOW, newWearable)
						if GameRules.CosmeticsList[wearableFX] and GameRules.CosmeticsList[wearableFX].control_points then
							for cp, attachtype in pairs(GameRules.CosmeticsList[wearableFX].control_points) do
								ParticleManager:SetParticleControlEnt(wFX, tonumber(cp), newWearable, PATTACH_POINT_FOLLOW, attachtype, newWearable:GetAbsOrigin(), true)
							end
						end
						ParticleManager:ReleaseParticleIndex(wFX)
					end
				end
				if GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particle_levelup then
					local fxName = GameRules.CosmeticsList[v] and GameRules.CosmeticsList[v].particle_levelup[tostring( self:GetItemManager():GetOtherLevel() )]
					local wFX = ParticleManager:CreateParticle(fxName, PATTACH_POINT_FOLLOW , newWearable)
					if GameRules.CosmeticsList[wearableFX] and GameRules.CosmeticsList[wearableFX].control_points then
						for cp, attachtype in pairs(GameRules.CosmeticsList[wearableFX].control_points) do
							ParticleManager:SetParticleControlEnt(wFX, tonumber(cp), newWearable, PATTACH_POINT_FOLLOW, attachtype, newWearable:GetAbsOrigin(), true)
						end
					end
					ParticleManager:ReleaseParticleIndex(wFX)
				end
				table.insert(self.otherWearableList, newWearable)
			elseif string.match(wearable, "vpcf") then
				local wearableFX = ParticleManager:CreateParticle(wearable, PATTACH_POINT_FOLLOW , hero)
				if GameRules.CosmeticsList[wearable] and GameRules.CosmeticsList[wearable].control_points then
					for cp, attachtype in pairs(GameRules.CosmeticsList[wearable].control_points) do
						ParticleManager:SetParticleControlEnt(wearableFX, tonumber(cp), hero, PATTACH_POINT_FOLLOW, attachtype, hero:GetAbsOrigin(), true)
					end
				end
				ParticleManager:ReleaseParticleIndex(wearableFX)
			end
		end
    end
end

function CDOTA_Item:GetWearables()
	if GameRules.AbilityKV[self:GetName()] and GameRules.AbilityKV[self:GetName()]["Wearables"] then return GameRules.AbilityKV[self:GetName()]["Wearables"] end
	return {}
end

function ItemManager:Destroy()
	self.passive:Destroy()
	UTIL_Remove(self)
end
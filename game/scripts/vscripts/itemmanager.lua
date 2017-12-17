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
			self:GetOwner():RemoveItem(self.armorTable[self:GetEquippedArmor()] )
		end
		self.currentArmor = self.currentArmor + 1
		self.equippedArmor = self:GetOwner():AddItemByName(self.armorTable[self.currentArmor])
		self:GetOwner():SetArmorWearables( self.equippedArmor:GetWearables() )
	else
		return print("Armor is maxed")
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
				local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model=v}):FollowEntity(self, true)
				table.insert(self.armorWearableList, newWearable)
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
		self.equippedWeapon = self:GetOwner():AddItemByName(self.weaponTable[self.currentWeapon])
		self:GetOwner():SetWeaponWearables( self.equippedWeapon:GetWearables() )
	else
		return "Weapon is maxed"
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
				local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model=v}):FollowEntity(self, true)
				table.insert(self.weaponWearableList, newWearable)
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
		self.equippedOther = self:GetOwner():AddItemByName(self.otherTable[self.currentOther])
		self:GetOwner():SetOtherWearables( self.equippedOther:GetWearables() )
	else
		return "Other is maxed"
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
				local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model=v}):FollowEntity(self, true)
				table.insert(self.otherWearableList, newWearable)
			end
		end
    end
end

function CDOTA_Item:GetWearables()
	if GameRules.AbilityKV[self:GetName()]["Wearables"] then return GameRules.AbilityKV[self:GetName()]["Wearables"] end
	return {}
end

function ItemManager:Destroy()
	self.passive:Destroy()
	UTIL_Remove(self)
end
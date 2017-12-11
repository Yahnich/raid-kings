revenant_penumbra_release = class({})
--------------------------------------------------------------------------------
function revenant_penumbra_release:OnSpellStart()
	local units = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag=DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
	for _,unit in pairs(units) do
		if unit:HasModifier("modifier_penumbra") then
			unit:RemoveModifierByName("modifier_penumbra")
		end
	end
end

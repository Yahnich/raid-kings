peacekeeper_indictment = class({})
--------------------------------------------------------------------------------
function peacekeeper_indictment:OnSpellStart()
	self.caster = self:GetCaster()
	self.cursorTar = self:GetCursorTarget()

	self.duration = self:GetSpecialValueFor("duration")

	if self.cursorTar:GetTeam() ~= self.caster:GetTeam() and not self.cursorTar:IsMagicImmune() then
		self.cursorTar:AddNewModifier(self.caster,self,"modifier_dazed_generic",{Duration = self.duration})
		EmitSoundOn("Hero_TemplarAssassin.Meld",self.cursorTar)
	end
end
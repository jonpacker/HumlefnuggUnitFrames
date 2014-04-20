local observeCombat = function()
  HFEventDelegate:on("combat-state", function(code, combat) 
    HFUF.playerFrame:setCombatState(combat)
    HFUF.targetFrame:setCombatState(combat)
  end)
end

function HFUF:create(parent)
	self.playerFrame = HFUnitFrame:create(parent, HFUnitModel:get('player'))
  self.playerFrame.container:SetSimpleAnchorParent(0, 0)
  self.targetFrame = HFUnitFrame:create(parent, HFUnitModel:get('reticleover', 'target-changed'))
  self.targetFrame.container:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
  observeCombat()
end
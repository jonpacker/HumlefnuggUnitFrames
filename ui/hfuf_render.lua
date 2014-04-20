local observeCombat = function()
  HFEventDelegate:on("combat-state", function(code, combat) 
    HFUF.playerFrame:setCombatState(combat)
    HFUF.targetFrame:setCombatState(combat)
  end)
end

function HFUF:create(parent)
	self.playerFrame = HFUnitFrame:create(parent, HFUnitModel:get('player'))
  self.targetFrame = HFUnitFrame:create(parent, HFUnitModel:get('reticleover'))
  observeCombat()
end
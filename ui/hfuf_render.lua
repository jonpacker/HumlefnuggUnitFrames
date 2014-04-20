local observeCombat = function()
  HFEventDelegate:on("combat-state", function(code, combat) 
    HFUF.playerFrame:setCombatState(combat)
  end)
end


function HFUF:create(parent)
	self.playerFrame = HFUnitFrame:create(parent, 'player')
  observeCombat()
end
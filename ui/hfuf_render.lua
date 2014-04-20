local observeCombat = function()
  HFEventDelegate:on("combat-state", function(code, combat) 
    HFUF.playerFrame:setCombatState(combat)
    HFUF.targetFrame:setCombatState(combat)
  end)
end

local observeTarget = function()
  HFEventDelegate:on("target-change", function()
    local targetName = GetUnitName('reticleover')
    if targetName == "" then
      HFUF.targetFrame.container:SetHidden(true)
    else
      HFUF.targetFrame.container:SetHidden(false)
      HFUF.targetFrame:reloadTarget()
  end)
end

function HFUF:create(parent)
	self.playerFrame = HFUnitFrame:create(parent, 'player')
  self.targetFrame = HFUnitFrame:create(parent, 'reticleover')
  observeCombat()
  observeTarget()
end
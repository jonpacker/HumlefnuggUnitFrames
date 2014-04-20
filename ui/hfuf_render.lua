function HFUF.render(parent)
	local playerFrame = HFUnitFrame:create(parent)
  playerFrame:addEventSource(HFUnitEventSource('player'))
end
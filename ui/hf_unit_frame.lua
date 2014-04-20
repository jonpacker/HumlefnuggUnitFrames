HFUnitFrame = {}
HFUnitFrame.__index = HFUnitFrame

local controlCounter = 0;
local getUniqueName = function(hint)
  controlCounter = controlCounter + 1
  return "HFUnitFrame_control_"..hint.."_"..controlCounter
end

local render = function(uf, parent)
  local container = WINDOW_MANAGER:CreateControl(getUniqueName("container"), parent, CT_TEXTURE)

  container:SetDimensions(uf.opts.width, uf.opts.height)
  container:SetColor(0, 0, 0, 0.25)
  container:SetAlpha(1)
  container:SetSimpleAnchorParent(0, 0)

  uf.container = container

  uf.healthBar = HFGrowbar:create(container, {
    fgColour = { 255, 0, 0, 1 };
    width = uf.opts.width;
    height = uf.opts.height / 3;
  })
  uf.magickaBar = HFGrowbar:create(container, {
    fgColour = { 0, 0, 255, 1 };
    width = uf.opts.width;
    height = uf.opts.height / 3;
  })
  uf.staminaBar = HFGrowbar:create(container, {
    fgColour = { 0, 255, 0, 1 };
    width = uf.opts.width;
    height = uf.opts.height / 3;
  })

  uf.magickaBar.container:SetSimpleAnchorParent(0, uf.opts.height / 3)
  uf.staminaBar.container:SetSimpleAnchorParent(0, uf.opts.height / 3 * 2)
end

function HFUnitFrame:create(parent, opts)
  local unitFrame = setmetatable({}, self)

  if opts == nil then opts = {} end

  -- defaults
  if opts.height == nil then opts.height = 100 end
  if opts.width == nil then opts.width = 300 end

  -- emitter
  EventEmitter:new(bar)

  unitFrame.opts = opts

  render(unitFrame, parent)

  return unitFrame
end
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
  container:SetColor(54/255, 54/255, 54/255, 1)
  container:SetAlpha(0.8)
  container:SetSimpleAnchorParent(0, 0)

  uf.container = container

  uf.healthBar = HFGrowbar:create(container, {
    fgColour = { 255/255, 46/255, 0, 1 };
    bgColour = { 54/255, 54/255, 54/255, 1 };
    width = uf.opts.width;
    height = uf.opts.height / 3;
  })
  uf.magickaBar = HFGrowbar:create(container, {
    fgColour = { 38/255, 94/255, 176/255, 1 };
    bgColour = { 54/255, 54/255, 54/255, 1 };
    width = uf.opts.width;
    height = uf.opts.height / 3;
  })
  uf.staminaBar = HFGrowbar:create(container, {
    fgColour = { 84/255, 189/255, 2/255, 1 };
    bgColour = { 54/255, 54/255, 54/255, 1 };
    width = uf.opts.width;
    height = uf.opts.height / 3;
  })

  uf.magickaBar.container:SetAnchor(TOPLEFT, uf.healthBar.container, BOTTOMLEFT, 0, 0)
  uf.staminaBar.container:SetAnchor(TOPLEFT, uf.magickaBar.container, BOTTOMLEFT, 0, 0)
end

local listen = function(uf)
  uf:on('health-update', function(current, total)
    uf.healthBar:update(current / total);
  end)

  uf:on('magicka-update', function(current, total)
    uf.magickaBar:update(current / total);
  end)

  uf:on('stamina-update', function(current, total)
    uf.staminaBar:update(current / total);
  end)
end

local defaults = {
  height = 80;
  width = 360;
};
defaults.__index = defaults;

function HFUnitFrame:create(parent, opts)
  local unitFrame = setmetatable({}, self)

  unitFrame.opts = setmetatable(opts or {}, defaults)
  EventEmitter:new(unitFrame)

  render(unitFrame, parent)
  listen(unitFrame)

  return unitFrame
end

function HFUnitFrame:addEventSource(es)
  es:pipe(self)
end
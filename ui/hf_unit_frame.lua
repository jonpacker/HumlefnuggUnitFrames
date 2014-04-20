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

  local barWidth = uf.opts.width - uf.opts.padding * 2
  local barVerticalSpace = uf.opts.height - uf.opts.padding * 2

  uf.healthBar = HFGrowbar:create(container, {
    fgColour = { 227/255, 94/255, 51/255, 1 };
    bgColour = { 30/255, 30/255, 30/255, 1 };
    width = barWidth;
    height = barVerticalSpace * 0.5 - uf.opts.padding;
  })
  uf.magickaBar = HFGrowbar:create(container, {
    fgColour = { 38/255, 94/255, 176/255, 1 };
    bgColour = { 30/255, 30/255, 30/255, 1 };
    width = barWidth;
    height = barVerticalSpace * 0.25 - uf.opts.padding;
  })
  uf.staminaBar = HFGrowbar:create(container, {
    fgColour = { 84/255, 189/255, 2/255, 1 };
    bgColour = { 30/255, 30/255, 30/255, 1 };
    width = barWidth;
    height = barVerticalSpace * 0.25 - uf.opts.padding;
  })

  uf.healthBar.container:SetAnchor(TOPLEFT, uf.container, TOPLEFT, uf.opts.padding, uf.opts.padding)
  uf.magickaBar.container:SetAnchor(TOPLEFT, uf.healthBar.container, BOTTOMLEFT, 0, uf.opts.padding)
  uf.staminaBar.container:SetAnchor(TOPLEFT, uf.magickaBar.container, BOTTOMLEFT, 0, uf.opts.padding)

  local charName = WINDOW_MANAGER:CreateControl(getUniqueName("charname"), uf.healthBar.container, CT_LABEL)
  charName:SetDimensions(barWidth / 2, uf.healthBar.opts.height)
  charName:SetSimpleAnchorParent(10, 0);
  charName:SetVerticalAlignment(TEXT_ALIGN_CENTER);
  charName:SetText(GetUnitName(uf.unit):upper());
  charName:SetFont(string.format("%s|%s|soft-shadow-thin", uf.opts.nameFont, math.floor(uf.opts.height / 4)))
  charName:SetColor(1, 1, 1, 1);
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
  padding = 2;
  nameFont = "HumlefnuggUnitFrames/libs/AlegreyaSansSC-ExtraBold.ttf";
};
defaults.__index = defaults;

function HFUnitFrame:create(parent, unit, opts)
  local unitFrame = setmetatable({}, self)

  unitFrame.opts = setmetatable(opts or {}, defaults)
  EventEmitter:new(unitFrame)
  unitFrame.unit = unit;

  render(unitFrame, parent)
  listen(unitFrame)

  HFUnitEventSource(unit):pipe(unitFrame)

  return unitFrame
end
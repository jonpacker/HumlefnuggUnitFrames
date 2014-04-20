HFUnitFrame = {}
HFUnitFrame.__index = HFUnitFrame

local controlCounter = 0;
local getUniqueName = function(hint)
  controlCounter = controlCounter + 1
  return "HFUnitFrame_control_"..hint.."_"..controlCounter
end

local updateIdentity = function(uf, parent)
  if not uf.unit.exists then
    uf.container:SetHidden(true)
    return
  end

  uf.container:SetHidden(false)
  uf.charName:SetText(uf.unit.name)
  uf.healthBar:update(uf.unit.health / uf.unit.healthMax, true)

  if uf.unit.hasMagicka then uf.magickaBar:update(uf.unit.magicka / uf.unit.magickaMax, true) end
  if uf.unit.hasStamina then uf.staminaBar:update(uf.unit.stamina / uf.unit.staminaMax, true) end
end

local renderHealthChangeIndicator = function(uf)
  local healthChange = WINDOW_MANAGER:CreateControl(getUniqueName("healthchange"), uf.healthBar.container, CT_LABEL)
  healthChange:SetDimensions(uf.healthBar.container:GetWidth() / 2, uf.healthBar.opts.height)
  healthChange:SetAnchor(TOPRIGHT, uf.healthBar.container, TOPRIGHT, -10, 0)
  healthChange:SetVerticalAlignment(TEXT_ALIGN_CENTER);
  healthChange:SetHorizontalAlignment(TEXT_ALIGN_RIGHT);
  healthChange:SetFont(string.format("%s|%s|soft-shadow-thin", uf.opts.nameFont, math.floor(uf.opts.healthHeight / 2)))
  healthChange:SetColor(255/255, 222/255, 78/255, 1);

  local fadeOutTimeline = ANIMATION_MANAGER:CreateTimeline()
  local fadeOut = fadeOutTimeline:InsertAnimation(ANIMATION_ALPHA, healthChange, 0);
  fadeOut:SetDuration(500);
  fadeOut:SetEasingFunction(ZO_EaseInQuintic);
  fadeOut:SetAlphaValues(1, 0);

  uf.unit:on('health-update', function()
    if uf.unit.healthDiff == 0 then return end
    fadeOutTimeline:Stop()
    local sign = uf.unit.healthDiff > 0 and "+" or "-"
    healthChange:SetText(string.format("%s%d", sign, math.abs(uf.unit.healthDiff)))
    fadeOutTimeline:PlayFromStart()
  end)
end

local render = function(uf, parent)
  local container = WINDOW_MANAGER:CreateControl(getUniqueName("container"), parent, CT_TEXTURE)

  container:SetColor(unpack(uf.opts.restingBg))

  uf.container = container

  local containerHeight = uf.opts.padding * 2 + uf.opts.healthHeight
  local barWidth = uf.opts.width - uf.opts.padding * 2

  uf.healthBar = HFGrowbar:create(container, {
    fgColour = { 227/255, 94/255, 51/255, 1 };
    bgColour = { 30/255, 30/255, 30/255, 1 };
    width = barWidth;
    height = uf.opts.healthHeight
  })
  uf.healthBar.container:SetAnchor(TOPLEFT, uf.container, TOPLEFT, uf.opts.padding, uf.opts.padding)

  if uf.unit.hasMagicka then
    uf.magickaBar = HFGrowbar:create(container, {
      fgColour = { 38/255, 94/255, 176/255, 1 };
      bgColour = { 30/255, 30/255, 30/255, 1 };
      width = barWidth;
      height = uf.opts.magickaHeight;
    })
    containerHeight = containerHeight + uf.opts.magickaHeight + uf.opts.padding
    uf.magickaBar.container:SetAnchor(TOPLEFT, uf.healthBar.container, BOTTOMLEFT, 0, uf.opts.padding)
  end

  if uf.unit.hasStamina then
    uf.staminaBar = HFGrowbar:create(container, {
      fgColour = { 84/255, 189/255, 2/255, 1 };
      bgColour = { 30/255, 30/255, 30/255, 1 };
      width = barWidth;
      height = uf.opts.staminaHeight
    })
    containerHeight = containerHeight + uf.opts.staminaHeight + uf.opts.padding
    -- assumes that the magicka bar exists, but i'm not sure there's any units that will have stamina without magicka.
    uf.staminaBar.container:SetAnchor(TOPLEFT, uf.magickaBar.container, BOTTOMLEFT, 0, uf.opts.padding)
  end

  container:SetDimensions(uf.opts.width, containerHeight)

  local charName = WINDOW_MANAGER:CreateControl(getUniqueName("charname"), uf.healthBar.container, CT_LABEL)
  charName:SetDimensions(barWidth / 2, uf.healthBar.opts.height)
  charName:SetSimpleAnchorParent(10, 0);
  charName:SetVerticalAlignment(TEXT_ALIGN_CENTER);
  charName:SetFont(string.format("%s|%s|soft-shadow-thin", uf.opts.nameFont, math.floor(uf.opts.healthHeight / 2)))
  charName:SetColor(1, 1, 1, 1);
  uf.charName = charName;

  if uf.opts.indicateHealthChange then
    renderHealthChangeIndicator(uf)
  end

  updateIdentity(uf);
end

local listen = function(uf)
  uf.unit:on('health-update', function(current, total)
    uf.healthBar:update(current / total);
  end)

  uf.unit:on('magicka-update', function(current, total)
    uf.magickaBar:update(current / total);
  end)

  uf.unit:on('stamina-update', function(current, total)
    uf.staminaBar:update(current / total);
  end)

  uf.unit:on('stats-update', function() 
    updateIdentity(uf)
  end)

  uf.unit:on('change-identity', function()
    updateIdentity(uf)
  end)
end

local defaults = {
  healthHeight = 40;
  magickaHeight = 25;
  staminaHeight = 25;
  width = 360;
  padding = 3;
  indicateHealthChange = false;
  restingBg = { 54/255, 54/255, 54/255, 0.4 };
  combatBg = { 90/255, 54/255, 54/255, 0.9 };
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

  return unitFrame
end

function HFUnitFrame:setCombatState(combat)
  if combat then
    self.charName:SetAlpha(0.1)
    self.container:SetColor(unpack(self.opts.combatBg))
  else
    self.charName:SetAlpha(1)
    self.container:SetColor(unpack(self.opts.restingBg))
  end
end

function HFUnitFrame:reloadTarget()
  uf.charName:SetText(GetUnitName(self.unit):upper())

end
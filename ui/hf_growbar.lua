HFGrowbar = {}
HFGrowbar.__index = HFGrowbar

local controlCounter = 0;
local getUniqueName = function(hint)
  controlCounter = controlCounter + 1
  return "HFGrowbar_control_"..hint.."_"..controlCounter
end

local fastForwardTimeline = function(tl)
  if tl:IsPlaying() then tl:PlayInstantlyToEnd() end
end

local animateWidthChange = function(bar)
  local timeline = ANIMATION_MANAGER:CreateTimeline()
  local anim = timeline:InsertAnimation(ANIMATION_SIZE, bar.bar, 0)
  anim:SetDuration(bar.opts.changeTime)
  anim:SetEasingFunction(bar.opts.changeEasing)
  anim:SetStartAndEndWidth(bar.opts.width, bar.opts.width)
  anim:SetStartAndEndHeight(bar.opts.height, bar.opts.height)

  bar:on("update", function(value)
    if value == bar.value then return end
    if timeline:IsPlaying() then timeline:PlayInstantlyToEnd() end
    timeline:PlayInstantlyToEnd()
    anim:SetStartAndEndWidth(bar.bar:GetWidth(), bar.opts.width * value)
    timeline:PlayFromStart()
  end)
end

local animateGlowOnChange = function(bar)
  local timeline = ANIMATION_MANAGER:CreateTimeline()
  timeline:InsertCallback(function()
    bar.glow:SetAlpha(bar.opts.glowMaxAlpha)
  end, 0)

  local disappear = timeline:InsertAnimation(ANIMATION_ALPHA, bar.glow, bar.opts.glowTime)
  disappear:SetDuration(bar.opts.glowTime / 2)
  disappear:SetEasingFunction(bar.opts.glowEasing)
  disappear:SetAlphaValues(bar.opts.glowMaxAlpha, 0)

  bar:on("update", function(value)
    if value == bar.value then return end
    timeline:Stop()
    widthDiff = value - bar.value
    bar.glow:SetWidth(math.abs(widthDiff) * bar.opts.width)
    timeline:PlayFromStart()
  end)
end

local render = function(bar, parent)
  local container = WINDOW_MANAGER:CreateControl(getUniqueName("container"), parent, CT_TEXTURE)
  local fillBar = WINDOW_MANAGER:CreateControl(getUniqueName("bar"), container, CT_TEXTURE)
  local glow = WINDOW_MANAGER:CreateControl(getUniqueName("glow"), fillBar, CT_TEXTURE)

  container:SetDimensions(bar.opts.width, bar.opts.height)
  container:SetColor(unpack(bar.opts.bgColour))
  container:SetSimpleAnchorParent(0, 0)

  fillBar:SetDimensions(bar.opts.width, bar.opts.height)
  fillBar:SetColor(unpack(bar.opts.fgColour))
  fillBar:SetSimpleAnchorParent(0, 0)

  glow:SetDimensions(0, bar.opts.height)
  glow:SetColor(1, 1, 1, bar.opts.glowMaxAlpha);
  glow:SetAnchor(TOPRIGHT, fillBar, TOPRIGHT, 0, 0)

  bar.container = container
  bar.bar = fillBar
  bar.glow = glow

  animateWidthChange(bar)
  animateGlowOnChange(bar)
end

local defaults = {
  bgColour = {0, 0, 0, 0.8}; -- background colour
  fgColour = {1, 1, 1, 1}; -- foreground colour
  changeTime = 100; -- bar width transition time in ms
  changeEasing = ZO_EaseOutQuintic; -- bar width transition easing function
  glowTime = 500; -- diff indicator display time in ms
  glowEasing = ZO_EaseInQuintic; -- diff indicator easing function
  glowMaxAlpha = 0.8;  -- max alpha of diff indicator
  height = 30; 
  width = 300;
};
defaults.__index = defaults;

-- Available options:
-- glowTime (ms): amount of time a gain glows. (default is 10000)
-- bgColour ({r,g,b,a}): background colour (defualt is black)
-- fgColour ({r,g,b,a}): foreground colour (default is white)
-- changeTime (ms): amount of time bar takes to change (animation)  (default is 100)
-- easing (fn): easing function (default is EASE_OUT_EXPO)
-- width: width of bar
-- height: height of bar
function HFGrowbar:create(parent, opts)
  local bar = setmetatable({}, self)
  bar.opts = setmetatable(opts or {}, defaults)
  EventEmitter:new(bar)
  bar.value = 1
  render(bar, parent)
  return bar
end

function HFGrowbar:update(newValue)
  self:emit("update", newValue)
  self.value = newValue;
end
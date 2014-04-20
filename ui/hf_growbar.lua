HFGrowbar = {}
HFGrowbar.__index = HFGrowbar

local EASE_OUT_EXPO = function (t, b, c, d)
  return c * ( -math.pow( 2, -10 * t/d ) + 1 ) + b;
end

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
  anim:SetEasingFunction(ZO_BezierInEase)
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

  local appear = timeline:InsertAnimation(ANIMATION_ALPHA, bar.glow, 0)
  appear:SetDuration(1)
  appear:SetAlphaValues(0, 1)

  local disappear = timeline:InsertAnimation(ANIMATION_ALPHA, bar.glow, bar.opts.glowTime / 2)
  disappear:SetDuration(bar.opts.glowTime / 2)
  disappear:SetAlphaValues(1, 0)

  bar:on("update", function(value)
    if value == bar.value then return end
    timeline:Stop()
    local widthDiff = math.abs(value - bar.value)
    bar.glow:SetWidth(widthDiff * bar.opts.width)
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
  glow:SetColor(1, 1, 1, 1);
  glow:SetAnchor(TOPRIGHT, fillBar, TOPRIGHT, 0, 0)

  bar.container = container
  bar.bar = fillBar
  bar.glow = glow

  animateGlowOnChange(bar)
  animateWidthChange(bar)
end

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

  if opts == nil then opts = {} end

  -- defaults
  if opts.glowTime == nil then opts.glowTime = 1000 end
  if opts.bgColour == nil then opts.bgColour = {0, 0, 0, 0.8} end
  if opts.fgColour == nil then opts.fgColour = {1, 1, 1, 1} end
  if opts.changeTime == nil then opts.changeTime = 100 end
  if opts.easing == nil then opts.easing = EASE_OUT_EXPO end
  if opts.height == nil then opts.height = 30 end
  if opts.width == nil then opts.width = 300 end

  -- emitter
  EventEmitter:new(bar)

  bar.opts = opts
  bar.value = 1

  render(bar, parent)

  return bar
end

function HFGrowbar:update(newValue)
  self:emit("update", newValue)
  self.value = newValue;
end
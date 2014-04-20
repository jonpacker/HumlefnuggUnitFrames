HFGrowbar = {}
HFGrowbar.__index = HFGrowbar

local controlCounter = 0;
local getUniqueName = function(hint)
  controlCounter = controlCounter + 1
  return "HFGrowbar_control_"..hint.."_"..controlCounter
end

local animateWidthChange = function(bar)
  local timeline = ANIMATION_MANAGER:CreateTimeline()
  local anim = timeline:InsertAnimation(ANIMATION_SIZE, bar.bar, 0)
  anim:SetDuration(bar.opts.changeTime)
  anim:SetEasingFunction(ZO_BezierInEase)

  bar:on("update", function(fill)
    timeline:Stop()
    anim:SetStartAndEndWidth(bar.bar:GetWidth(), bar.opts.width * fill)
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

  bar:on("update", function(fill)
    timeline:Stop()
    local widthDiff = math.abs(fill - bar.fill)
    bar.glow:SetWidth(widthDiff * bar.opts.width)
    timeline:PlayFromStart()
  end)
end

local render = function(self, parent)
  local container = WINDOW_MANAGER:CreateControl(getUniqueName("container"), parent, CT_TEXTURE)
  local bar = WINDOW_MANAGER:CreateControl(getUniqueName("bar"), container, CT_TEXTURE)
  local glow = WINDOW_MANAGER:CreateControl(getUniqueName("glow"), bar, CT_TEXTURE)

  container:SetDimensions(self.opts.width, self.opts.height)
  container:SetColor(unpack(self.opts.bgColour))
  bar:SetDimensions(width, height)
  bar:SetColor(unpack(self.opts.fgColour))
  glow:SetDimensions(0, height)
  glow:SetColor({1, 1, 1, 1});
  glow:SetAnchor(TOPRIGHT, bar, TOPRIGHT, 0, 0)

  self.container = container
  self.bar = bar
  self.glow = glow

  animateGlowOnChange(self)
  animateWidthChange(self)
end

-- Available options:
-- glowTime (ms): amount of time a gain glows. (default is 10000)
-- bgColour ({r,g,b,a}): background colour (defualt is black)
-- fgColour ({r,g,b,a}): foreground colour (default is white)
-- changeTime (ms): amount of time bar takes to change (animation)  (default is 100)
-- easing (fn): easing function (default is ZO_BezierInEase)
-- width: width of bar
-- height: height of bar
function HFGrowbar:create(parent, opts)
  local bar = setmetatable({}, self)

  if opts == nil then opts = {} end

  -- defaults
  if opts.glowTime == nil then opts.glowTime = 10000 end
  if opts.bgColour == nil then opts.bgColour = {0, 0, 0, 0.8} end
  if opts.fgColour == nil then opts.fgColour = {1, 1, 1, 1} end
  if opts.changeTime == nil then opts.changeTime = 100 end
  if opts.easing == nil then opts.easing = ZO_BezierInEase end
  if opts.height == nil then opts.height = 30 end
  if opts.width == nil then opts.width = 300 end

  -- emitter
  EventEmitter:new(bar)

  bar.opts = opts
  bar.fill = 1

  render(bar, parent)

  return bar
end

function HFGrowbar:update(newFillPercent)
  self:emit("update", newFillPercent)
  self.fill = newFillPercent;
end
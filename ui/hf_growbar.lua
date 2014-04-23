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

  bar:on("update", function(value, immediate)
    if value == bar.value then return end

    if timeline:IsPlaying() then timeline:PlayInstantlyToEnd() end

    if immediate or bar.collapsed then
      bar.bar:SetWidth(bar.opts.width * value)
      return
    end

    anim:SetStartAndEndHeight(bar.bar:GetHeight(), bar.bar:GetHeight())
    anim:SetStartAndEndWidth(bar.bar:GetWidth(), bar.opts.width * value)
    timeline:PlayFromStart()
  end)
end

local animateGlowOnChange = function(bar)
  function createGlowTimeline(control)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:InsertCallback(function()
      control:SetAlpha(bar.opts.glowMaxAlpha)
      control:SetWidth(0)
    end, 0)
    timeline:InsertCallback(function()
      control.animateTo = nil
    end, bar.opts.glowTime)

    local disappear = timeline:InsertAnimation(ANIMATION_ALPHA, control, 0)
    disappear:SetDuration(bar.opts.glowTime)
    disappear:SetEasingFunction(bar.opts.glowEasing)
    disappear:SetAlphaValues(bar.opts.glowMaxAlpha, 0)

    local expand = timeline:InsertAnimation(ANIMATION_SIZE, control, 0)
    expand:SetDuration(bar.opts.changeTime)
    expand:SetEasingFunction(bar.opts.changeEasing)
    expand:SetStartAndEndWidth(0, 0)
    expand:SetStartAndEndHeight(bar.opts.height, bar.opts.height)

    return timeline, disappear, expand
  end

  local gainTimeline, gainDisappear, gainExpand = createGlowTimeline(bar.gain)
  local loseTimeline, loseDisappear, loseExpand = createGlowTimeline(bar.lose)

  bar:on("update", function(value, immediate)
    if value == bar.value or immediate or bar.collapsed then return end

    if gainTimeline:IsPlaying() then gainTimeline:PlayInstantlyToEnd() end
    if loseTimeline:IsPlaying() then loseTimeline:PlayInstantlyToEnd() end

    local widthDiff = (value - bar.value) * bar.opts.width
    local animateTo = math.abs(widthDiff)

    if widthDiff < 0 then
      loseExpand.animatingTo = animateTo
      loseExpand:SetStartAndEndHeight(bar.lose:GetHeight(), bar.lose:GetHeight())
      loseExpand:SetStartAndEndWidth(0, animateTo)
      loseTimeline:PlayFromStart()
    else
      gainExpand.animatingTo = animateTo
      gainExpand:SetStartAndEndHeight(bar.gain:GetHeight(), bar.gain:GetHeight())
      gainExpand:SetStartAndEndWidth(0, animateTo)
      gainTimeline:PlayFromStart()
    end
  end)
end

local createCollapseTimeline = function(bar)
  local timeline = ANIMATION_MANAGER:CreateTimeline()

  local collapseControl = function(control)
    local anim = timeline:InsertAnimation(ANIMATION_SIZE, control, 0)
    anim:SetEasingFunction(bar.opts.collapseEasing)
    anim:SetDuration(bar.opts.collapseTime)
    anim:SetStartAndEndWidth(control:GetWidth(), control:GetWidth())
    anim:SetStartAndEndHeight(control:GetHeight(), 0)
    return anim
  end

  local collapsedControls = { bar.container, bar.bar, bar.gain, bar.lose }
  local collapseAnims = {}
  for i = 1, #collapsedControls do 
    collapseAnims[i] = collapseControl(collapsedControls[i])
  end

  local updateWidths = function()
    for i, control in ipairs(collapsedControls) do
      collapseAnims[i]:SetStartAndEndWidth(control:GetWidth(), control.animatingTo or control:GetWidth())
    end
  end

  bar:on('collapse', function() 
    if timeline:IsPlaying() then timeline:PlayInstantlyToEnd() end
    updateWidths()
    timeline:PlayForward()
  end)
  bar:on('expand', function() 
    if timeline:IsPlaying() then timeline:PlayInstantlyToEnd() end
    updateWidths()
    timeline:PlayBackward()
  end)
end

local render = function(bar, parent)
  local container = WINDOW_MANAGER:CreateControl(getUniqueName("container"), parent, CT_TEXTURE)
  local fillBar = WINDOW_MANAGER:CreateControl(getUniqueName("bar"), container, CT_TEXTURE)
  local gain = WINDOW_MANAGER:CreateControl(getUniqueName("gain"), fillBar, CT_TEXTURE)
  local lose = WINDOW_MANAGER:CreateControl(getUniqueName("lose"), fillBar, CT_TEXTURE)

  container:SetDimensions(bar.opts.width, bar.opts.height)
  container:SetColor(unpack(bar.opts.bgColour))

  fillBar:SetDimensions(bar.opts.width, bar.opts.height)
  fillBar:SetColor(unpack(bar.opts.fgColour))
  fillBar:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)

  gain:SetDimensions(0, bar.opts.height)
  gain:SetColor(1, 1, 1, bar.opts.glowMaxAlpha);
  gain:SetAnchor(TOPRIGHT, fillBar, TOPRIGHT, 0, 0)

  lose:SetDimensions(0, bar.opts.height)
  lose:SetColor(unpack(bar.opts.fgColour));
  lose:SetAnchor(TOPLEFT, fillBar, TOPRIGHT, 0, 0)

  bar.container = container
  bar.bar = fillBar
  bar.gain = gain
  bar.lose = lose

  animateWidthChange(bar)
  animateGlowOnChange(bar)

  if bar.opts.collapsible then
    createCollapseTimeline(bar)
  end
end

local defaults = {
  bgColour = {0, 0, 0, 0.8}; -- background colour
  fgColour = {1, 1, 1, 1}; -- foreground colour
  changeTime = 150; -- bar width transition time in ms
  changeEasing = ZO_EaseOutQuintic; -- bar width transition easing function
  glowTime = 500; -- diff indicator display time in ms
  glowEasing = ZO_EaseInQuintic; -- diff indicator easing function
  glowMaxAlpha = 0.5;  -- max alpha of diff indicator
  height = 30; 
  width = 300;
  collapsible = false;
  collapseEasing = ZO_EaseInOutCubic;
  collapseTime = 300;
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
  bar.collapsed = false
  render(bar, parent)
  return bar
end

function HFGrowbar:update(newValue, immediate)
  self:emit("update", newValue, immediate)
  self.value = newValue;
end

function HFGrowbar:expand()
  if self.opts.collapsible then
    self:emit('expand')
    self.collapsed = false
  end
end

function HFGrowbar:collapse()
  if self.opts.collapsible then
    self:emit('collapse')
    self.collapsed = true
  end
end
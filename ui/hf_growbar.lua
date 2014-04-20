HFGrowbar = {}
HFGrowbar.__index = HFGrowbar

-- Available options:
-- glowTime (ms): amount of time a gain glows. 
function HFGrowbar:create(parent, width, height, colour, opts)
  local bar = setmetatable({}, self)

  if opts == nil then opts = {} end
  if opts.glowTime == nil then opts.glowTime = 10000 end

  bar:render()

  return bar
end
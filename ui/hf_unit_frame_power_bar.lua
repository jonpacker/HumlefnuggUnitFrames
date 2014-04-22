HFUnitFramePowerBar = {}
HFUnitFramePowerBar.__index = HFUnitFramePowerBar

local defaults = {
  height = 20;
  colour = { 1, 1, 1, 1 };
};

local render = function(pb)
  
end

defaults.__index = defaults;
function HFUnitFramePowerBar:create(uf, power, opts)
  local bar = setmetatable({}, self)

  bar.opts = setmetatable(opts or {}, defaults)
  bar.uf = uf
  bar.power = power

  render(bar)

  return bar
end
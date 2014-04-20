HFUnitModel = {}
HFUnitModel.__index = HFUnitModel

local unitModelPool = {}

local updateUnit = function(unit)
  unit.name = GetUnitName(unit.unit)

  if unit.name == "" then
    unit.exists = false
    unit:emit('update')
    return
  else
    unit.exists = true
  end

  unit.level = GetUnitLevel(unit.unit)
  unit.health, unit.healthMax, unit.healthEffectiveMax = GetUnitPower(unit.unit, POWERTYPE_HEALTH)
  unit.hasMagicka = GetUnitPower(unit.unit, POWERTYPE_MAGICKA) ~= 0
  unit.hasStamina = GetUnitPower(unit.unit, POWERTYPE_STAMINA) ~= 0

  if unit.hasStamina then
    unit.stamina, unit.staminaMax, unit.staminaEffectiveMax = GetUnitPower(unit.unit, POWERTYPE_STAMINA)
  end

  if unit.hasMagicka then
    unit.magicka, unit.magickaMax, unit.magickaEffectiveMax = GetUnitPower(unit.unit, POWERTYPE_MAGICKA)
  end

end

local listenForChanges = function(unit, changeEvent)
  unit:on('magicka-update', function(magicka, magickaMax, magickaEffectiveMax)
    unit.magicka, unit.magickaMax, unit.magickaEffectiveMax = magicka, magickaMax, magickaEffectiveMax
  end)
  unit:on('stamina-update', function(stamina, staminaMax, staminaEffectiveMax)
    unit.stamina, unit.staminaMax, unit.staminaEffectiveMax = stamina, staminaMax, staminaEffectiveMax
  end)
  unit:on('health-update', function(health, healthMax, healthEffectiveMax)
    unit.health, unit.healthMax, unit.healthEffectiveMax = health, healthMax, healthEffectiveMax
  end)
  unit:on('stats-update', function()
    updateUnit(unit)
  end)

  if changeEvent then
    HFEventDelegate:on(changeEvent, function() 
      updateUnit(unit)
      unit:emit('change-identity')
    end)
  end
end

local init = function(unit, changeEvent)
  listenForChanges(unit, changeEvent);
  updateUnit(unit)
end

function HFUnitModel:get(unitName, changeEvent)
  if unitModelPool[unitName] then return unitModelPool[unitName] end

  local unit = setmetatable({}, HFUnitModel)
  EventEmitter:new(unit)
  HFUnitEventSource(unitName):pipe(unit)
  unit.unit = unitName

  init(unit, changeEvent)

  return unit 
end
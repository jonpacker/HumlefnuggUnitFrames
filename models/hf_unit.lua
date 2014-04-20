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
    unit.outgoingStamina = unit.stamina
  end

  if unit.hasMagicka then
    unit.magicka, unit.magickaMax, unit.magickaEffectiveMax = GetUnitPower(unit.unit, POWERTYPE_MAGICKA)
    unit.outgoingMagicka = unit.magicka
  end

end

local listenForChanges = function(unit, changeEvent)
  function updatePower(powerType)
    return function(power, powerMax, powerEffectiveMax)
      unit[powerType.."Outgoing"] = unit[powerType]
      unit[powerType.."MaxOutgoing"] = unit[powerType.."Max"]
      unit[powerType.."EffectiveMaxOutgoing"] = unit[powerType.."EffectiveMax"] 
      unit[powerType.."Diff"] = power - unit[powerType]
      unit[powerType.."MaxDiff"] = powerMax - unit[powerType.."Max"]
      unit[powerType.."EffectiveMaxDiff"] = powerEffectiveMax - unit[powerType.."EffectiveMax"]
      unit[powerType], unit[powerType.."Max"], unit[powerType.."EffectiveMax"] = power, powerMax, powerEffectiveMax
    end
  end

  unit:on('magicka-update', updatePower('magicka'))
  unit:on('stamina-update', updatePower('stamina'))
  unit:on('health-update', updatePower('health'))

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
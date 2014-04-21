HFUnitModel = {}
HFUnitModel.__index = HFUnitModel

local unitModelPool = {}

local difficulties = {}
difficulties[MONSTER_DIFFICULTY_DEADLY] = 'deadly'
difficulties[MONSTER_DIFFICULTY_EASY] = 'easy'
difficulties[MONSTER_DIFFICULTY_HARD] = 'hard'
difficulties[MONSTER_DIFFICULTY_NONE] = ''
difficulties[MONSTER_DIFFICULTY_NORMAL] = 'normal'

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
  unit.veteran = IsUnitVeteran(unit.unit)
  unit.veteranRank = GetUnitVeteranRank(unit.unit)
  unit.class = GetUnitClass(unit.unit)
  unit.race = GetUnitRace(unit.unit)
  unit.desc = GetUnitCaption(unit.unit)

  if GetUnitDifficulty(unit.unit) then
    unit.difficulty = difficulties[GetUnitDifficulty(unit.unit)]
    unit.difficultyDecoration = ""
    -- stole this bit from FTC. credit to them!
    unit.difficultyRank = math.max(GetUnitDifficulty(unit.unit) - 1, 0)
    for i = 1, unit.difficultyRank do unit.difficultyDecoration = unit.difficultyDecoration .. "!" end
  else
    unit.difficulty, unit.difficultyDecoration, unit.difficultyRank = nil, nil, nil
  end

  unit.decoratedName = unit.name
  if unit.difficultyRank and unit.difficultyRank > 0 then
    unit.decoratedName = unit.decoratedName .. " (" .. unit.difficultyDecoration .. ")"
  end

  unit.caption = unit.veteran and "VR"..unit.veteranRank or tostring(unit.level)

  if unit.desc then unit.caption = unit.caption .. " " .. unit.desc end
  if unit.race then unit.caption = unit.caption .. " " .. unit.race end
  if unit.class then unit.caption = unit.caption .. " " .. unit.class end

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
HFUnitModel = {}
HFUnitModel.__index = HFUnitModel

local unitModelPool = {}

local difficulties = {}
difficulties[MONSTER_DIFFICULTY_DEADLY] = 'deadly'
difficulties[MONSTER_DIFFICULTY_EASY] = 'easy'
difficulties[MONSTER_DIFFICULTY_HARD] = 'hard'
difficulties[MONSTER_DIFFICULTY_NONE] = ''
difficulties[MONSTER_DIFFICULTY_NORMAL] = 'normal'

-- Bloody stupid that ZOS removed this from the API. It's rather easy to use a super basic heuristic to work around it.
-- I haven't found a case where this returns a false positive yet (`powerMax` should always be non-nil if the unit uses that power)
local doesUnitUsePowerType = function(unit, powertype)
  local powerValue, powerMax = GetUnitPower(unit, powertype);
  return powerValue ~= 0 and powerMax ~= nil
end

function updatePower(unit, powerType)
  return function(power, powerMax, powerEffectiveMax)
    unit[powerType.."Outgoing"] = unit[powerType]
    unit[powerType.."MaxOutgoing"] = unit[powerType.."Max"]
    unit[powerType.."EffectiveMaxOutgoing"] = unit[powerType.."EffectiveMax"] 

    if unit[powerType] ~= nil then
      unit[powerType.."Diff"] = power - unit[powerType]
      unit[powerType.."MaxDiff"] = powerMax - unit[powerType.."Max"]
      unit[powerType.."EffectiveMaxDiff"] = powerEffectiveMax - unit[powerType.."EffectiveMax"]
    end

    unit[powerType], unit[powerType.."Max"], unit[powerType.."EffectiveMax"] = power, powerMax, powerEffectiveMax
  end
end

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
  unit.inCombat = IsUnitInCombat(unit.unit)

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

  unit.hasMagicka = doesUnitUsePowerType(unit.unit, POWERTYPE_MAGICKA)
  unit.hasStamina = doesUnitUsePowerType(unit.unit, POWERTYPE_STAMINA)
  unit.hasMount = doesUnitUsePowerType(unit.unit, POWERTYPE_MOUNT_STAMINA)

  if unit.hasStamina then
    updatePower(unit, 'stamina')(GetUnitPower(unit.unit, POWERTYPE_STAMINA))
  end

  if unit.hasMagicka then
    updatePower(unit, 'magicka')(GetUnitPower(unit.unit, POWERTYPE_MAGICKA))
  end

  if unit.hasMount then
    updatePower(unit, 'mountStamina')(GetUnitPower(unit.unit, POWERTYPE_MOUNT_STAMINA))
    unit.isMounted = unit.unit == 'player' and IsMounted()

    if unit.unit == 'player' then
      unit.mountName = GetStableSlotInfo(ACTIVE_MOUNT_INDEX)
      unit.mountLevel = GetStableSlotMountStats(ACTIVE_MOUNT_INDEX)
    end
  end
end

local listenForChanges = function(unit, changeEvent)
  unit:on('magicka-update', updatePower(unit, 'magicka'))
  unit:on('stamina-update', updatePower(unit, 'stamina'))
  unit:on('health-update', updatePower(unit, 'health'))
  unit:on('mount-stamina-update', updatePower(unit, 'mountStamina'))

  unit:on('stats-update', function()
    updateUnit(unit)
  end)

  unit:on('mounted-update', function(mounted)
    unit.isMounted = mounted
  end)

  if unit.unit == 'player' then
    HFEventDelegate:on('combat-state', function(code, inCombat)
      unit.inCombat = inCombat
      unit:emit('combat-state', inCombat)
    end)
  end

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
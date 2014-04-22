HFEventDelegate:add(EVENT_POWER_UPDATE, "power-update")
HFEventDelegate:add(EVENT_STATS_UPDATED, "stats-update")
HFEventDelegate:add(EVENT_MOUNTED_STATE_CHANGED, "mount-update")

local eventSources = {}

function HFUnitEventSource(unit)
  if eventSources[unit] ~= nil then return eventSources[unit] end

  eventSources[unit] = EventEmitter:new()
  local es = eventSources[unit]

  HFEventDelegate:on("power-update", function(eventCode, eventUnit, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unit ~= eventUnit then return end

    local eventName = nil
    if powerType == POWERTYPE_HEALTH then
      eventName = "health-update"
    elseif powerType == POWERTYPE_MAGICKA then
      eventName = "magicka-update"
    elseif powerType == POWERTYPE_STAMINA then
      eventName = "stamina-update"
    elseif powerType == POWERTYPE_MOUNT_STAMINA then
      eventName = "mount-stamina-update"
    end

    if eventName ~= nil then
      es:emit(eventName, powerValue, powerMax, powerEffectiveMax)
    end
  end)

  HFEventDelegate:on("stats-update", function(event, targetUnit)
    if unit == targetUnit then
      es:emit("stats-update")
    end
  end)

  if unit == "player" then
    HFEventDelegate:on("mount-update", function(event, mounted)
      es:emit("mount-update", mounted)
    end)
  end

  return es
end


HFEventDelegate:add(EVENT_POWER_UPDATE, "power-update")
HFEventDelegate:add(EVENT_STATS_UPDATED, "stats-update")
HFEventDelegate:add(EVENT_MOUNTED_STATE_CHANGED, "mounted-update")
HFEventDelegate:add(EVENT_MOUNTS_FULL_UPDATE, "mount-update")
HFEventDelegate:add(EVENT_MOUNT_UPDATE, "mount-update")
HFEventDelegate:add(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, "add-visual") 
HFEventDelegate:add(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, "remove-visual")
HFEventDelegate:add(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED , "update-visual")

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
    HFEventDelegate:on("mounted-update", function(event, mounted)
      es:emit("mounted-update", mounted)
    end)
    HFEventDelegate:on("mount-update", function(event)
      es:emit("mount-update")
    end)
  end

  HFEventDelegate:on("add-visual", function(event, targetUnit, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    if unit ~= targetUnit then return end
    es:emit("add-visual", unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
  end)
  HFEventDelegate:on("remove-visual", function(event, targetUnit, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    if unit ~= targetUnit then return end
    es:emit("remove-visual", unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
  end)
  HFEventDelegate:on("update-visual", function(event, targetUnit, unitAttributeVisual, statType, attributeType, powerType, oldValue, value, oldMax, maxValue)
    if unit ~= targetUnit then return end
    es:emit("update-visual", unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
  end)

  es:on("add-visual", function(unitAttributeVisual, statType, attributeType, powerType, value, max)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and powerType == POWERTYPE_HEALTH then
      es:emit("gain-health-shield", value, max)
    end
  end)
  es:on("remove-visual", function(unitAttributeVisual, statType, attributeType, powerType, value, max)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and powerType == POWERTYPE_HEALTH then
      es:emit("lose-health-shield")
    end
  end)
  es:on("update-visual", function(unitAttributeVisual, statType, attributeType, powerType, value, max)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and powerType == POWERTYPE_HEALTH then
      es:emit("update-health-shield", value, max)
    end
  end)

  return es
end


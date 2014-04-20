local delegate = EventEmitter:new()
local delegateGlobalEventTo = function(globalEvent, localEvent)
  EVENT_MANAGER:RegisterForEvent("HFUF", globalEvent, function(...)
    delegate:emit(localEvent, ...)
  end)
end

delegateGlobalEventTo(EVENT_POWER_UPDATE, "power-update")

local eventSources = {}

function HFUnitEventSource(unit)
  if eventSources[unit] ~= nil then return eventSources[unit] end

  eventSources[unit] = EventEmitter:new()
  local es = eventSources[unit]

  delegate:on("power-update", function(eventCode, eventUnit, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unit ~= eventUnit then return end
  
    local eventName = nil
    if powerType == POWERTYPE_HEALTH then
      eventName = "health-update"
    elseif powerType == POWERTYPE_HEALTH then
      eventName = "magicka-update"
    elseif powerType == POWERTYPE_STAMINA then
      eventName = "stamina-update"
    end
    
    if eventName ~= nil then
      es:emit(eventName, powerValue, powerMax, powerEffectiveMax)
    end
  end)
end


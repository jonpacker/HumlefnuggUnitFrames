local piped = {}

HFEventDelegate = EventEmitter:new()
function HFEventDelegate:add(globalEvent, localEvent)
  local pipesForThisEvent = piped[globalEvent] or {}
  if pipesForThisEvent[localEvent] then return end

  pipesForThisEvent[localEvent] = true
  piped[globalEvent] = pipesForThisEvent
  EVENT_MANAGER:RegisterForEvent("HFUF"..localEvent, globalEvent, function(...)
    self:emit(localEvent, ...)
  end)
end
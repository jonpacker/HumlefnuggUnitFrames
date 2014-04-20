EventEmitter = {}

function EventEmitter.init(self)
  if not self then
    self = {}
    setmetatable(self, {__index = EventEmitter})
  end
  self._listeners = {}
  self._pipes = {}
  return self
end

function EventEmitter:emit(event_name, ...)
  local listeners = self._listeners[event_name]
  local pipes = self._pipes
  if not listeners then return end
  for _, listener in pairs(listeners) do
    if "function" == type(listener) then
      listener(...)
    end
  end
  for _, pipe in pairs(pipes) do
    pipe:emit(event_name, ...)
  end
end

function EventEmitter:pipe(to)
  self._pipes[#self._pipes + 1] = to
  return #self._pipes
end

function EventEmitter:on(event_name, callback)
  local listeners = self._listeners[event_name] or {}
  listeners[#listeners + 1] = callback
  self._listeners[event_name] = listeners
  return #listeners
end

function EventEmitter:once(event_name, callback)
  
  local function once_handler(...)
    self:remove_listener(event_name, once_handler)
    callback(...)
  end
  
  self:on(event_name, once_handler)
end

function EventEmitter:remove_listener(event_name, callback)
  local listeners = self._listeners[event_name]
  if not listeners then return false end
  
  for index, listener in pairs(listeners) do
    if listener == callback then
      table.remove(listeners, index)
      return true
    end
  end
  
  return false
end

function EventEmitter:listeners(event_name)
  if event_name then
    return self._listeners[event_name]
  else
    return self._listeners
  end
end
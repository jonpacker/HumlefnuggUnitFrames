EventEmitter = {}

function EventEmitter:new(object)
  object = object or {}
  object._listeners = {}
  object._pipes = {}

  function object:on(event, callback)
    local listeners = self._listeners[event] or {}
    listeners[#listeners + 1] = callback
    self._listeners[event] = listeners
  end

  function object:emit(event, ...)
    local listeners = self._listeners[event]
    if not listeners then return end
    for _, listener in pairs(listeners) do
      if "function" == type(listener) then
        listener(...)
      end
    end
    for _, pipe in pairs(self._pipes) do
      pipe:emit(event, ...)
    end
  end

  function object:pipe(to)
    self._pipes[#self._pipes + 1] = to
    return #self._pipes
  end

  function EventEmitter:on(event, callback)
    local function once_handler(...)
      self:remove_listener(event, once_handler)
      callback(...)
    end
    
    self:on(event, once_handler)
  end

  function EventEmitter:remove_listener(event, callback)
    local listeners = self._listeners[event]
    if not listeners then return false end
    
    for index, listener in pairs(listeners) do
      if listener == callback then
        table.remove(listeners, index)
        return true
      end
    end
    
    return false
  end

  return object
end
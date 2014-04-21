EventEmitter = {}

function EventEmitter:new(object)
  object = object or {}
  local _listeners = {}
  local _pipes = {}

  function object:on(event, callback)
    local listeners = _listeners[event] or {}
    listeners[#listeners + 1] = callback
    _listeners[event] = listeners
  end

  function object:emit(event, ...)
    local listeners = _listeners[event]

    if listeners ~= nil then
      for _, listener in pairs(listeners) do
        if "function" == type(listener) then
          listener(...)
        end
      end
    end

    if #_pipes > 0 then
      for _, pipe in pairs(_pipes) do
        pipe:emit(event, ...)
      end
    end
  end

  function object:pipe(to)
    _pipes[#_pipes + 1] = to
    return #_pipes
  end

  function object:once(event, callback)
    local function once_handler(...)
      self:remove_listener(event, once_handler)
      callback(...)
    end
    
    self:on(event, once_handler)
  end

  function object:remove_listener(event, callback)
    local listeners = _listeners[event]
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
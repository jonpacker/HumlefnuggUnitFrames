--ported from underscore.js
--[[
original license:

Copyright (c) 2009-2014 Jeremy Ashkenas, DocumentCloud and Investigative
Reporters & Editors

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]--

function hf_debounce(func, wait, immediate)
  local timeout, args, timestamp, result, later

  later = function()
    local last = GetGameTimeMilliseconds() - timestamp;

    if last < wait and last > 0 then
      zo_callLater(later, wait - last)
      timeout = true
    else
      timeout = false
      if not immediate then
        result = func(unpack(args))
        args = nil
      end
    end
  end

  return function(...)
    args = {...}
    timestamp = GetGameTimeMilliseconds();
    local callNow = immediate and not timeout;
    if not timeout then
      zo_callLater(later, wait)
      timeout = true
    end
    if callNow then
      result = func(...)
      args = nil
    end

    return result
  end
end
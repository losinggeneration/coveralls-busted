local Coveralls
Coveralls = require("coveralls.coveralls").Coveralls
local busted = require('busted')
local handler = assert(require("busted.outputHandlers.TAP"))
if os.getenv('LOCAL') then
  Coveralls.service_name = Coveralls.Local
end
if os.getenv('COVERALLS_DEBUG') then
  Coveralls.service_name = Coveralls.Debug
end
local coverallsStart
coverallsStart = function()
  Coveralls:start()
  return nil, true
end
local coverallsEnd
coverallsEnd = function()
  Coveralls:stop()
  if Coveralls.dirname ~= "" then
    Coveralls:coverDir(Coveralls.dirname, Coveralls.ext)
  end
  local _list_0 = Coveralls:srcs()
  for _index_0 = 1, #_list_0 do
    local src = _list_0[_index_0]
    Coveralls:cover(src["name"])
  end
  Coveralls:send()
  return nil, true
end
busted.subscribe({
  'suite',
  'start'
}, coverallsStart)
busted.subscribe({
  'suite',
  'end'
}, coverallsEnd)
return handler

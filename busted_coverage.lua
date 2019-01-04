local Coveralls
Coveralls = require("coveralls.coveralls").Coveralls
local busted = require('busted')
local handler = assert(require("busted.outputHandlers.base"))
if os.getenv('LOCAL') then
  Coveralls.service_name = Coveralls.Local
end
if os.getenv('COVERALLS_DEBUG') then
  Coveralls.service_name = Coveralls.Debug
end
local coverallsTestStart
coverallsTestStart = function()
  Coveralls:start()
  return nil, true
end
local coverallsTestEnd
coverallsTestEnd = function()
  Coveralls:stop()
  return nil, true
end
local coverallsSuiteStart
coverallsSuiteStart = function()
  Coveralls:start()
  return nil, true
end
local coverallsSuiteEnd
coverallsSuiteEnd = function()
  Coveralls:stop()
  local moon = require("moon")
  local _
  do
    local _base_0 = Coveralls
    local _fn_0 = _base_0.process_positions
    _ = function(...)
      return _fn_0(_base_0, ...)
    end
  end
  moon.p(Coveralls.positions)
  moon.p(Coveralls:format_results())
  if Coveralls.dirname ~= "" then
    Coveralls:coverDir(Coveralls.dirname, Coveralls.ext)
  end
  local _list_0 = Coveralls.srcs
  for _index_0 = 1, #_list_0 do
    local src = _list_0[_index_0]
    Coveralls:cover(src)
  end
  Coveralls:send()
  return nil, true
end
busted.subscribe({
  'suite',
  'start'
}, coverallsSuiteStart)
busted.subscribe({
  'suite',
  'end'
}, coverallsSuiteEnd)
busted.subscribe({
  'test',
  'start'
}, coverallsTestStart)
busted.subscribe({
  'test',
  'end'
}, coverallsTestEnd)
return handler

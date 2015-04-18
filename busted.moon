import Coveralls from require "coveralls.coveralls"
busted = require 'busted'
handler = assert require "busted.outputHandlers.TAP"

Coveralls.service_name = Coveralls.Local if os.getenv 'LOCAL'
Coveralls.service_name = Coveralls.Debug if os.getenv 'COVERALLS_DEBUG'

coverallsStart = ->
	Coveralls\start!
	return nil, true

coverallsEnd = ->
	Coveralls\stop!
	Coveralls\coverDir Coveralls.dirname, Coveralls.ext if Coveralls.dirname != ""
	Coveralls\cover src for src in *Coveralls.srcs
	Coveralls\send!

	return nil, true

busted.subscribe { 'suite', 'start' }, coverallsStart
busted.subscribe { 'suite', 'end' }, coverallsEnd

handler

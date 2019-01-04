import Coveralls from require "coveralls"
busted = require 'busted'
handler = assert require "busted.outputHandlers.base"

Coveralls.service_name = Coveralls.Local if os.getenv 'LOCAL'
Coveralls.service_name = Coveralls.Debug if os.getenv 'COVERALLS_DEBUG'

coverallsTestStart = ->
	print "coveralls test start"
	Coveralls\start!
	return nil, true

coverallsTestEnd = ->
	print "coveralls test end"
	Coveralls\stop!
	return nil, true

coverallsSuiteStart = ->
	print "coveralls suite start"
	Coveralls\start!
	return nil, true

coverallsSuiteEnd = ->
	print "coveralls suite end"
	Coveralls\stop!
	moon = require "moon"
	Coveralls\process_positions
	moon.p Coveralls.positions
	moon.p Coveralls\format_results!
	Coveralls\coverDir Coveralls.dirname, Coveralls.ext if Coveralls.dirname != ""
	Coveralls\cover src for src in *Coveralls.srcs
	Coveralls\send!

	return nil, true

busted.subscribe { 'suite', 'start' }, coverallsSuiteStart
busted.subscribe { 'suite', 'end' }, coverallsSuiteEnd
--busted.subscribe { 'test', 'start' }, coverallsTestStart
--busted.subscribe { 'test', 'end' }, coverallsTestEnd

handler

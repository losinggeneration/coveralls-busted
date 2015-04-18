-- Based heavily on busted.outputHandlers.TAP

(options) ->
	import Coveralls from require "coveralls.coveralls"
	busted = require 'busted'
	handler = (assert require "busted.outputHandlers.base")!

	success = 'ok %u - %s'
	failure = 'not ' .. success
	skip = 'ok %u - # SKIP %s'
	counter = 0

	Coveralls.service_name = Coveralls.Local if os.getenv 'LOCAL'
	Coveralls.service_name = Coveralls.Debug if os.getenv 'COVERALLS_DEBUG'

	handler.suiteReset = ->
		counter = 0
		return nil, true

	handler.suiteEnd = ->
		print '1..' .. counter

		Coveralls\coverDir Coveralls.dirname, Coveralls.ext if Coveralls.dirname != ""
		Coveralls\cover src for src in *Coveralls.srcs
		Coveralls\send!

		return nil, true

	handler.testStart = (element, parent) ->
		Coveralls\start!
		return nil, true

	handler.testEnd = (element, parent, status, trace) ->
		Coveralls\stop!

		counter = counter + 1
		if status == 'success' then
			t = handler.successes[#handler.successes]
			print(success\format(counter, t.name))
		elseif status == 'pending' then
			t = handler.pendings[#handler.pendings]
			print(skip\format(counter, (t.message or t.name)))
		elseif status == 'failure' then
			showFailure(handler.failures[#handler.failures])
		elseif status == 'error' then
			showFailure(handler.errors[#handler.errors])

		return nil, true

	handler.error = (element, parent, message, debug) ->
		if element.descriptor ~= 'it' then
			counter = counter + 1
			showFailure(handler.errors[#handler.errors])

		return nil, true

	busted.subscribe { 'suite', 'reset' }, handler.suiteReset
	busted.subscribe { 'suite', 'end' }, handler.suiteEnd
	busted.subscribe { 'test', 'start' }, handler.testStart
	busted.subscribe { 'test', 'end' }, handler.testEnd
	busted.subscribe { 'error' }, handler.error

	handler

coverage = require "coveralls.coverage"
require "json"

export ^

-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--
-- This copyright applies to formencodepart and formencode
formencodepart = (s) ->
	return s and s\gsub "%W", (c) ->
			if c ~= " "
				string.format "%%%02x", c\byte!
			else
				"+"

formencode = (form) ->
	result = {}
	if form[1] -- Array of ordered { name, value }
		for _, field in ipairs form  do
			table.insert result, formencodepart(field.name).."="..formencodepart(field.value)
	else -- Unordered map of name -> value
		for name, value in pairs(form) do
			table.insert result, formencodepart(name).."="..formencodepart(value)

	table.concat result, "&"

class coveralls extends coverage.CodeCoverage
	Travis: "travis-ci"
	Jenkins: "jenkins"
	Semaphore: "semaphore"
	Circle: "circleci"
	Local: "local"
	Debug: "debug"

	new: =>
		@__source_files = {}
		-- The continuous integration service
		@service_name = @@Travis
		-- The continuous integration service job id
		@service_job_id = nil
		-- The secret repo token for your repository, found at the bottom of
		-- your repository's page on Coveralls.
		@repo_token = nil

		@dirname = ''
		@ext = '*.moon'

		super!

	coverDir: (dirname, ext = '*.moon') =>
		dir = require "pl.dir"
		@cover f for f in *(dir.getfiles dirname, ext)
		@coverDir d, ext for d in *(dir.getdirectories dirname)

	cover: (fname) =>
		file_coverage = @file_coverage fname
		return unless file_coverage
		c = file_coverage.coverage

		length = #c
		if length == 0
			i = 1
			for line in io.lines fname
				c[i] = if coveralls.no_coverage(line)
						json.util.null
					else
						0
				i += 1
		else
			for k, v in pairs c
				length = k if k > length

			for i = 1, length
				file_coverage.coverage[i] = json.util.null if c[i] == nil


		table.insert @__source_files, file_coverage if #c > 0

	srcs: => @__source_files

	send: =>
		if #@__source_files == 0
			print "\nNo source files to send to Coveralls"
			return

		if not @service_job_id
			env = nil
			switch @service_name
				when @@Travis
					env = 'TRAVIS_JOB_ID'
				when @@Jenkins
					env = 'BUILD_NUMBER'
				when @@Semaphore
					env = 'SEMAPHORE_BUILD_NUMBER'
				when @@Circle
					env = 'CIRCLE_BUILD_NUM'
				when @@Local
					return
				when @@Debug
					moon = require "moon"
					moon.p @__source_files
					json_data = json.encode {
						service_name: @service_name,
						service_job_id: @service_job_id,
						repo_token: @repo_token,
						source_files: @__source_files,
					}
					print json_data
					print #json_data
					form_data = formencode { json: json_data }
					print form_data
					print #form_data
					return

			@service_job_id = os.getenv env

		assert @service_job_id, "A service_job_id must be specified"

		form_data = formencode {
			json: json.encode {
				service_name: @service_name,
				service_job_id: @service_job_id,
				repo_token: @repo_token,
				source_files: @__source_files,
			}
		}

		https = require "ssl.https"
		require "socket"
		retry = 0
		send = ->
			body, code, headers, status = https.request 'https://coveralls.io/api/v1/jobs', form_data

			-- HTML response. sleep 30 seconds and try again
			if body\match "^<"
				print "Coveralls returned HTML. This shouldn't happen. Trying again in 30 seconds"
				retry += 1
				return 500, "Failed to get a correct response from coveralls.io", {message: "Service may be unavailable"} if retry > 5
				socket.select(nil, nil, 30)
				return send!

			code, status, json.decode body

		code, status, msg = send!

		assert code == 200, string.format "Error updating Coveralls: (status: %s) (response: %s)", status, msg.message
		print msg.url

Coveralls = coveralls!

{ :Coveralls }

require "busted"

describe "coverage", ->
	coverage = (require "coverage").CodeCoverage!
	moon = require "moon"
	moonscript = require "moonscript"
	it "coverage", ->
		cd1_loader, err = moonscript.loadfile "tests/coverage_data1.moon"
		print err if err
		coverage\start!
		cd1 = cd1_loader!
		f = cd1.F!
		coverage\stop!

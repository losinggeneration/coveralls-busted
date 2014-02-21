x = -> print "x"

-- A comment

class F
	new: (x = 0, y = 1) =>
		@x = 0 if x
		@y = 1 if y


	test1: => @x
	test2: =>
		if @x
			@x
	test3: => if @x
			@x
		else
			@x

{ :x, :F }
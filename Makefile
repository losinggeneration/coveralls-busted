LUA_OBJS := $(patsubst %.moon, %.lua, $(wildcard *.moon))

all: $(LUA_OBJS)

test:
	busted -m ?.moon -p _spec.moon$$ tests

ci: busted_coverage.lua
	busted -o busted_coverage -m ?.moon -p _spec.moon$$ tests

%.lua: %.moon
	moonc $<

.PHONY: all test ci

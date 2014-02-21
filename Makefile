LUA_OBJS := $(patsubst %.moon, %.lua, $(wildcard *.moon))

all: $(LUA_OBJS)

test:
	busted -m ?.moon -p _spec.moon$$ tests

ci: busted.lua
	busted -o busted.lua -m ?.moon -p _spec.moon$$ tests

%.lua: %.moon
	moonc $<

.PHONY: all test ci

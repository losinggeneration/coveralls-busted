LUA_OBJS := $(patsubst %.moon, %.lua, $(wildcard *.moon))

all: $(LUA_OBJS)

%.lua: %.moon
	moonc $<

.PHONY: all

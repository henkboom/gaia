LUA_DIR=dokidoki-support/lua-5.1.4

linux:
	make gaia sensor.so PLATFORM=linux \
		MODULE_FLAGS="-lhighgui -shared"

macosx:
	make gaia sensor.so PLATFORM=macosx \
		MODULE_FLAGS="-lhighgui -bundle -undefined dynamic_lookup"

gaia:
	make -C dokidoki-support $(PLATFORM) NAME=../gaia

sensor.so: sensor.c
	gcc -O2 -Wall -o $@ $^ -I$(LUA_DIR)/src $(MODULE_FLAGS)

clean:
	make -C dokidoki-support clean NAME=../gaia

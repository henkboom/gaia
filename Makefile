LUA_DIR=dokidoki-support/lua-5.1.4

linux:
	make gaia sensor.so PLATFORM=linux

macosx:
	make gaia sensor.so PLATFORM=macosx

gaia: 
	make -C dokidoki-support $(PLATFORM) NAME=../gaia

sensor.so: sensor.c
	gcc -g -O0 -o $@ $^ -I$(LUA_DIR)/src -lhighgui -shared

clean:
	make -C dokidoki-support clean NAME=../gaia

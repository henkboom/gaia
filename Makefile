LUA_DIR=dokidoki-support/lua-5.1.4

linux:
	make gaia sensor.so capture.so PLATFORM=linux \
		MODULE_FLAGS="-lhighgui -shared"

macosx:
	make gaia sensor.so capture.so PLATFORM=macosx MACOSX_DEPLOYMENT_TARGET=10.4 \
		MODULE_FLAGS="-lhighgui -lcv -lcxcore -bundle -undefined dynamic_lookup"

.PHONY: gaia

gaia:
	make -C dokidoki-support $(PLATFORM) NAME=../gaia

%.so: %.c
	gcc -O2 -Wall -fPIC -o $@ $^ -I$(LUA_DIR)/src $(MODULE_FLAGS)

clean:
	make -C dokidoki-support clean NAME=../gaia
	rm -rf sensor.so

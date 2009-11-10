linux:
	make gaia PLATFORM=linux

macosx:
	make gaia PLATFORM=macosx

gaia: 
	make -C dokidoki-support $(PLATFORM) NAME=../gaia

clean:
	make -C dokidoki-support clean NAME=../gaia

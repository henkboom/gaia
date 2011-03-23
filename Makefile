# set the default rule
build:

# OS detection, cut at 7 chars for mingw
UNAME := $(shell uname | cut -c 1-7)
ifeq ($(UNAME), Linux)
PLATFORM := LINUX
endif
ifeq ($(UNAME), Darwin)
PLATFORM := MACOSX
endif
ifeq ($(UNAME), MINGW32)
PLATFORM := MINGW
endif

# initialize variables, load project settings
PROJECT_NAME := unnamed
LIBRARIES :=
CFLAGS :=
LDFLAGS :=
LINUX_CFLAGS :=
LINUX_LDFLAGS :=
MACOSX_CFLAGS :=
MACOSX_LDFLAGS :=
MINGW_CFLAGS :=
MINGW_LDFLAGS :=
LUA_SRC :=
LUA_NATIVE_MODULES :=

include project.dd
include $(LIBRARIES:%=%/project.dd)

# now initialize other variables from the project settings
TARGET_DIR := $(PROJECT_NAME)
TARGET_EXE := $(TARGET_DIR)/$(PROJECT_NAME)

OBJS := $(C_SRC:.c=.o)
DEPS := $(C_SRC:.c=.P)
LUA_TARGETS=$(LUA_SRC:%=$(TARGET_DIR)/%)
RESOURCE_TARGETS=$(RESOURCES:%=$(TARGET_DIR)/%)

# start the actual rules
build: $(TARGET_EXE) resources $(LIBRARY_RESOURCES)
resources: $(LUA_TARGETS) $(RESOURCE_TARGETS)

$(TARGET_EXE): $(OBJS)
	@echo linking $@...
	@mkdir -p `dirname $@`
	@gcc -o $@ $^ $(LDFLAGS) $($(PLATFORM)_LDFLAGS)

%.o: %.c
	@echo building $@...
	@gcc -MD -o $@ $< -c $(CFLAGS) $($(PLATFORM)_CFLAGS)
	@cp $*.d $*.P;
	@sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	     -e '/^$$/ d' -e 's/$$/ :/' < $*.d >> $*.P
	@rm -f $*.d

$(RESOURCE_TARGETS): $(TARGET_DIR)/%: %
	@echo copying $@...
	@mkdir -p `dirname $@`
	@cp $^ $@

$(LUA_TARGETS): $(TARGET_DIR)/%: %
	@echo verifying $@...
	@luac -p $^
	@echo copying $@...
	@mkdir -p `dirname $@`
	@cp $^ $@

clean:
	rm -f $(OBJS) $(DEPS)
	rm -rf $(TARGET_DIR)

-include $(DEPS)

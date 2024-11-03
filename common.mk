DEPS = 
SRC_DIR = src
BUILD_DIR = build

ifdef ARCH
	CROSS_COMPILE ?= $(ARCH)-linux-gnu-
endif
ifdef CROSS_COMPILE
	# FIXME we need something between `=` and `?=` that does not respect builtins, but respects MAKEOVERRIDES
	CC = $(CROSS_COMPILE)gcc
	CPP = $(CROSS_COMPILE)cpp
	CXX = $(CROSS_COMPILE)g++
	AR = $(CROSS_COMPILE)ar
	AS = $(CROSS_COMPILE)as
endif
LD ?= $(CROSS_COMPILE)ld
NM ?= $(CROSS_COMPILE)nm
OBJCOPY ?= $(CROSS_COMPILE)objcopy
OBJDUMP ?= $(CROSS_COMPILE)objdump
STRIP ?= $(CROSS_COMPILE)strip
PKGCONFIG ?= $(CROSS_COMPILE)pkg-config

CFLAGS = -Wall -Wextra
ifdef DEBUG
	CFLAGS += -Og -gdwarf-2
	CPPFLAGS += -D DEBUG
else
	CFLAGS += -O2
endif
ifneq ($(strip $(DEPS)),)
	CPPFLAGS += $(shell $(PKGCONFIG) --cflags $(DEPS))
	LDLIBS += $(shell $(PKGCONFIG) --libs $(DEPS))
endif
INCPATH += -iquote $(SRC_DIR)
ENSURE_DIR = mkdir -p $(shell dirname "$@")
COMPILE_EXE = $(CC) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@
COMPILE_DLL = $(CC) -shared $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

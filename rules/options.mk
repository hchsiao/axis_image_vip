TEST_DIR       ?= $(shell pwd)
CACHE_DIR      := $(TEST_DIR)/cache

PYTHON_BIN     := python

# Set V=1 when calling make to enable verbose output
# mainly for debugging purposes.
ifeq ($(V), 1)
Q=
else
Q ?=@
endif

# Construct include paths
SV_INCL ?=
SV_INCL := $(foreach d, $(SV_INCL), +incdir+$(d))

NCSIM_FLAGS = +nc64bit +sv +access+r -mccodegen +nctimescale+1ns/1ps
RTL_FLAGS   = +nospecify

SV_SRCS    := $(SV_SRCS) $(BENCH_DIR)/src/tb_top.sv

# make rules
all: run

cache-dir:
	$(Q)mkdir -p $(CACHE_DIR)

seq: cache-dir
	$(Q)cd $(CACHE_DIR) &&\
		$(PYTHON_BIN) $(TEST_DIR)/src/utils/img2axis.py $(TEST_IMG) test_pattern.txt

run: cache-dir seq
	$(Q)cd $(CACHE_DIR) &&\
		ncverilog $(NCSIM_FLAGS) $(SIM_PARAMS) $(DUMP_FLAG) $(RTL_FLAGS) $(SV_INCL) $(SV_SRCS)



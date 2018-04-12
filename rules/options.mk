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

IUS_FLAGS = +nc64bit +sv +access+r -mccodegen +nctimescale+1ns/1ps
VCS_FLAGS = +vcs+fsdbon -gui -kdb -lca +memcbk +vcs+fsdbon+struct -full64 +systemverilogext+.sv+.svh -override_timescale=1ns/1ps
RTL_FLAGS   = +nospecify

SV_SRCS    := $(SV_SRCS) $(BENCH_DIR)/src/tb_top.sv

# make rules
all: run

cache-dir:
	$(Q)mkdir -p $(CACHE_DIR)

seq: cache-dir
	$(Q)cd $(CACHE_DIR) &&\
		$(PYTHON_BIN) -B $(BENCH_DIR)/src/utils/img2axis.py $(TEST_IMG) test_pattern.txt

ius: cache-dir seq
	$(Q)cd $(CACHE_DIR) &&\
		ncverilog $(IUS_FLAGS) $(SIM_PARAMS) $(DUMP_FLAG) $(RTL_FLAGS) $(SV_INCL) $(SV_SRCS)

cache/simv: cache-dir
	$(Q)cd $(CACHE_DIR) &&\
		vcs $(VCS_FLAGS) $(SIM_PARAMS) $(DUMP_FLAG) $(RTL_FLAGS) $(SV_INCL) $(SV_SRCS)

vcs: cache-dir seq cache/simv
	$(Q)cd $(CACHE_DIR) &&\
		./simv -verdi



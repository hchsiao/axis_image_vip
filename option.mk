CACHE_DIR      := $(TEST_DIR)/cache

# Set V=1 when calling make to enable verbose output
# mainly for debugging purposes.
ifeq ($(V), 1)
Q=
else
Q ?=@
endif

# Construct waveform flags
DUMP_FLAG=
ifeq ($(VCD), 1)
DUMP_FLAG:="$(DUMP_FLAG) +define+DUMP_VCD_PATH='\"sim_dump.vcd\"'"
endif

ifeq ($(SHM), 1)
DUMP_FLAG:="$(DUMP_FLAG) +define+DUMP_SHM_PATH='\"sim_dump.shm\"'"
endif

ifeq ($(FSDB), 1)
DUMP_FLAG:="$(DUMP_FLAG) +define+DUMP_FSDB_PATH='\"sim_dump.fsdb\"'"
endif

# Construct include paths
SV_INCL:=
SV_INCL:="$(SV_INCL) +incdir+$(CACHE_DIR)/svlog"

NCSIM_FLAGS = +nc64bit +sv +access+r -mccodegen +nctimescale+1ns/1ps
DPI_FLAGS   = +sv_lib=pydpi_bridge.so
RTL_FLAGS   = +nospecify

SV_SRCS    := $(SV_SRCS) $(BENCH_DIR)/src/test.sv

# make rules
all: run

cache-dir:
	$(Q)mkdir -p $(CACHE_DIR)
	$(Q)mkdir -p $(CACHE_DIR)/python/
	$(Q)mkdir -p $(CACHE_DIR)/svlog/

cache/pydpi_bridge.so:
	pydpi-build

code-gen: cache-dir
	# generate testbench codes
	$(Q)cd $(BENCH_DIR) &&\
		pydpi-gen-mod &&\
		pydpi-gen &&\
		pydpi-gen-param
	# merging cache
	-$(Q)cp $(TEST_DIR)/svlog-cfg.yaml $(CACHE_DIR)
	-$(Q)cp $(BENCH_DIR)/cache/python/* $(CACHE_DIR)/python/
	-$(Q)cp $(BENCH_DIR)/cache/svlog/* $(CACHE_DIR)/svlog/
	# generate project specific codes
	$(Q)cd $(TEST_DIR) &&\
		pydpi-gen-mod &&\
		pydpi-gen &&\
		pydpi-gen-param

run: cache-dir code-gen cache/pydpi_bridge.so
	$(Q)cd $(CACHE_DIR) &&\
		export PYTHONPATH=$(CACHE_DIR)/python/:$(PYTHONPATH) &&\
		ncverilog $(NCSIM_FLAGS) $(DPI_FLAGS) $(DUMP_FLAG) $(RTL_FLAGS) $(SV_INCL) $(SV_SRCS)



TEST_DIR       := $(shell pwd)
BENCH_DIR      := $(TEST_DIR)

SV_SRCS        := $(TEST_DIR)/src/strm_proc_wrapper.sv

# include python-svlog build system makefile
include $(BENCH_DIR)/option.mk

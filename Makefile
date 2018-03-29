RESET_DELAY    := 1
RESET_DURATION := 3.51
CLOCK_PERIOD   := 33

BENCH_DIR       := $(shell pwd)
TEST_DIR        := $(BENCH_DIR)

SV_INCL        := $(BENCH_DIR)

SV_SRCS        := "\
	$(BENCH_DIR)/src/fixture.sv \
	"

TEST_IMG       := $(TEST_DIR)/data/img/test_128_100.bmp

include $(BENCH_DIR)/rules/testbench.mk

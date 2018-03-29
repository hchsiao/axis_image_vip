# simulation params check
ifndef RESET_DELAY
$(error RESET_DELAY is not set)
endif
ifndef RESET_DURATION
$(error RESET_DURATION is not set)
endif
ifndef CLOCK_PERIOD
$(error CLOCK_PERIOD is not set)
endif

SIM_PARAMS := " \
	+define+RESET_DELAY=$(RESET_DELAY) \
	+define+RESET_DURATION=$(RESET_DURATION) \
	+define+CLOCK_PERIOD=$(CLOCK_PERIOD) \
	"

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


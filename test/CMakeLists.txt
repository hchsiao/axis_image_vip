cmake_minimum_required(VERSION 2.8)

include(ChipCMake)
find_package(VCS)
find_package(PythonInterp)

set(test_rec_file test_pattern.txt)
set(test_image ${CMAKE_CURRENT_SOURCE_DIR}/data/img/test_128_100.bmp)
add_custom_command(OUTPUT ${test_rec_file}
  COMMAND ${PYTHON_EXECUTABLE} -B ${CMAKE_SOURCE_DIR}/utils/img2axis.py ${test_image} ${test_rec_file}
  COMMENT "Generating test pattern record file"
  )
add_custom_target(test_rec DEPENDS ${test_rec_file})

set(SIM_FLAGS
	"+define+RESET_DELAY=1"
	"+define+RESET_DURATION=3.51"
	"+define+CLOCK_PERIOD=33")
if(${FSDB})
  list(APPEND SIM_FLAGS "+define+DUMP_FSDB_PATH='\"sim_dump.fsdb\"'")
endif()

file(GLOB test_sources *.sv)
add_testbench(pipelined_fb ${test_sources}
  FLAGS ${SIM_FLAGS}
  )
add_dependencies(pipelined_fb test_rec)


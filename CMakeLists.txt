cmake_minimum_required(VERSION 2.8)
project(axis_image_vip)

include(ChipCMake)

file(GLOB design_sources src/*.sv)
specify_design(
  SOURCES ${design_sources}
  NO_SYNTH
  )

configure_parameters(POSTFIX config.svh
  PARAM_LIST
    SOURCE_BYTES
    SINK_BYTES
  )

include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_testbench_subdirectory(test)


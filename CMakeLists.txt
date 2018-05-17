cmake_minimum_required(VERSION 2.8)
project(axis_image_vip)

include(ChipCMake)

file(GLOB design_sources src/*.sv)
specify_design(
  SOURCES ${design_sources}
  NO_SYNTH
  )

set(AXIS_IMAGE_VIP_SOURCE_BYTES 1 CACHE STRING "VIP output byte count")
set(AXIS_IMAGE_VIP_SINK_BYTES 1 CACHE STRING "VIP input byte count")
configure_file(config.svh.in config.svh)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_testbench_subdirectory(test)


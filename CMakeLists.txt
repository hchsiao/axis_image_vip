cmake_minimum_required(VERSION 2.8)
project(axis_image_vip)

include(ChipCMake)

configure_parameters(
  SOURCE_BYTES
  SINK_BYTES
  TIMEOUT_CYCLE
  )
configure_file(${PROJECT_NAME}_config.svh.in ${PROJECT_NAME}_config.svh)

file(GLOB design_sources src/*.sv)
specify_design(
  SOURCES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_config.svh ${design_sources}
  NO_SYNTH
  )

hdl_include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_testbench_subdirectory(test)


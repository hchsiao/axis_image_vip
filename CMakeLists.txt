cmake_minimum_required(VERSION 2.8)
project(axis_image_vip)

include(ChipCMake)

file(GLOB design_sources src/*.sv)
add_design(axis_image_vip ${design_sources})
include_directories(${CMAKE_SOURCE_DIR})

add_subdirectory(test)

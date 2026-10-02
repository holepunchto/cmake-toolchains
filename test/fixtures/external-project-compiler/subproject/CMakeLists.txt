cmake_minimum_required(VERSION 3.25)

project(subproject NONE)

if(CMAKE_TOOLCHAIN_FILE)
  message(FATAL_ERROR "Expected no toolchain, got '${CMAKE_TOOLCHAIN_FILE}'")
endif()

cmake_minimum_required(VERSION 3.25)

project(subproject C)

if(NOT CMAKE_C_COMPILER STREQUAL EXPECTED_C_COMPILER)
  message(FATAL_ERROR "Expected '${EXPECTED_C_COMPILER}', got '${CMAKE_C_COMPILER}'")
endif()

add_executable(exe main.c)

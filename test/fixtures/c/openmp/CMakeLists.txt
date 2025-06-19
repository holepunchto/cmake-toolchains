cmake_minimum_required(VERSION 3.31)

project(lib C)

find_package(OpenMP REQUIRED)

add_library(lib STATIC lib.c)

target_link_libraries(
  lib
  PRIVATE
    OpenMP::OpenMP_C
)

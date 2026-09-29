cmake_minimum_required(VERSION 3.25)

project(undefined C)

add_library(lib SHARED lib.c)

add_executable(exe main.c)

target_link_libraries(exe PRIVATE lib)

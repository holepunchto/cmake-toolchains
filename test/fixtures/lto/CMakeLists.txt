cmake_minimum_required(VERSION 3.25)

project(lto C)

add_library(lib STATIC lib.c)

target_compile_options(lib PRIVATE -flto)

add_executable(exe main.c)

target_link_options(exe PRIVATE -flto)

target_link_libraries(exe PRIVATE lib)

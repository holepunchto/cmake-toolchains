cmake_minimum_required(VERSION 3.25)

project(leak C)

add_library(lib SHARED lib.c)

add_executable(exe main.c)

target_link_libraries(exe PRIVATE lib)

enable_testing()

add_test(NAME exe COMMAND exe)

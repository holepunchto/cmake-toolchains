cmake_minimum_required(VERSION 3.25)

project(whole_archive C)

add_library(lib STATIC lib.c)

add_executable(exe main.c)

target_link_libraries(exe PRIVATE $<LINK_LIBRARY:WHOLE_ARCHIVE,lib>)

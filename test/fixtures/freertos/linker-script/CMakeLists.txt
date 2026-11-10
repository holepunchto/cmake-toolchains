cmake_minimum_required(VERSION 3.25)

project(linker_script C)

add_executable(exe main.c)

target_link_options(exe PRIVATE "-T${CMAKE_CURRENT_LIST_DIR}/board.ld")

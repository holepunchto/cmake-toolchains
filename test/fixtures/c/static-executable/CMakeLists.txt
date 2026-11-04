cmake_minimum_required(VERSION 3.25)

project(exe C)

add_executable(exe main.c)

target_link_options(exe PRIVATE -static)

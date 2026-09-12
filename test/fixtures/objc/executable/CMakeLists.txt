cmake_minimum_required(VERSION 3.25)

project(exe OBJC)

add_executable(exe main.m)

target_link_libraries(exe PRIVATE "-framework Foundation")

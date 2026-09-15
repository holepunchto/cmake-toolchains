cmake_minimum_required(VERSION 3.25)

project(exe OBJCXX)

add_executable(exe main.mm)

target_link_libraries(exe PRIVATE "-framework Foundation")

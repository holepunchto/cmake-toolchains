cmake_minimum_required(VERSION 3.29)

project(kernel C)

enable_testing()

add_executable(exe main.c)

add_test(NAME exit COMMAND exe exit)

set_tests_properties(exit PROPERTIES WILL_FAIL TRUE)

add_test(NAME tick COMMAND exe tick)

add_test(NAME tasks COMMAND exe tasks)

set_tests_properties(tasks PROPERTIES PASS_REGULAR_EXPRESSION "worker local=2\nmain local=1\n")

# Linking an executable that uses nothing from the C library or the kernel
# itself still pulls in the runner, the kernel and the heap.
add_executable(empty empty.c)

# The runner is linked even into an executable that links without a keyword.
target_link_libraries(empty m)

add_test(NAME empty COMMAND empty)

set_tests_properties(exit tick tasks empty PROPERTIES TIMEOUT 10)

# A library doesn't link the runner, so it can be installed with an export set
# that the runner isn't in.
add_library(lib STATIC empty.c)

install(TARGETS lib EXPORT kernel)

install(EXPORT kernel DESTINATION lib/cmake)

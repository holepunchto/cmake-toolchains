cmake_minimum_required(VERSION 3.29)

project(qemu C)

enable_testing()

add_executable(exe main.c)

add_test(NAME print COMMAND exe print "a,b")

set_tests_properties(print PROPERTIES PASS_REGULAR_EXPRESSION "^a,b\n$")

add_test(NAME exit-success COMMAND exe exit 0)

add_test(NAME exit-failure COMMAND exe exit 3)

add_test(NAME abort COMMAND exe abort 0)

set_tests_properties(exit-failure abort PROPERTIES WILL_FAIL TRUE)

add_test(NAME alloc COMMAND exe alloc 0x200000)

set_tests_properties(print exit-success exit-failure abort alloc PROPERTIES TIMEOUT 10)

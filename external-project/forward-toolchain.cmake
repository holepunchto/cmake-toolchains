include_guard(GLOBAL)

include(ExternalProject)

# `ExternalProject_Add()` configures a CMake project without the toolchain of
# the project adding it, which leaves the compiler to whatever the host has.
# Passing the toolchain as a cache default lets one the caller names win.
#
# A caller that names a compiler instead is left alone too, as the compiler a
# toolchain sets would otherwise override it.
#
# Each argument is passed as a bracket argument, as expanding `ARGN` would drop
# empty ones, such as the one in `CONFIGURE_COMMAND ""`.
function(ExternalProject_Add name)
  set(args "[==[${name}]==]")

  set(forward ON)

  set(i 1)

  while(i LESS ARGC)
    set(arg "${ARGV${i}}")

    string(APPEND args " [==[${arg}]==]")

    if(arg MATCHES "^-DCMAKE_(TOOLCHAIN_FILE|[A-Za-z]+_COMPILER)(:[A-Z]+)?=")
      set(forward OFF)
    endif()

    math(EXPR i "${i} + 1")
  endwhile()

  if(forward)
    string(APPEND args " CMAKE_CACHE_DEFAULT_ARGS [==[-DCMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_TOOLCHAIN_FILE}]==]")
  endif()

  cmake_language(EVAL CODE "_ExternalProject_Add(${args})")
endfunction()

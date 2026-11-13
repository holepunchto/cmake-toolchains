# Runs an executable under QEMU and exits with its status, when invoked as:
#
#   cmake -P qemu-run.cmake <qemu> [<option>...] -- <executable> [<arg>...]
#
# The executable and its arguments are handed to it as its command line through
# semihosting, which splits the command line on spaces.

set(qemu)
set(config "enable=on,target=native")
set(executable)
set(separated FALSE)

math(EXPR last "${CMAKE_ARGC} - 1")

foreach(i RANGE 3 ${last})
  set(arg "${CMAKE_ARGV${i}}")

  if(separated)
    if(NOT executable)
      set(executable "${arg}")
    endif()

    # QEMU escapes commas in option values by doubling them.
    string(REPLACE "," ",," arg "${arg}")

    string(APPEND config ",arg=${arg}")
  elseif(arg STREQUAL "--")
    set(separated TRUE)
  else()
    list(APPEND qemu "${arg}")
  endif()
endforeach()

if(NOT executable)
  message(FATAL_ERROR "Usage: cmake -P qemu-run.cmake <qemu> [<option>...] -- <executable> [<arg>...]")
endif()

execute_process(
  COMMAND ${qemu} -semihosting-config "${config}" -kernel "${executable}"
  RESULT_VARIABLE status
)

if(NOT status MATCHES "^[0-9]+$")
  message(FATAL_ERROR "QEMU did not exit: ${status}")
endif()

cmake_language(EXIT ${status})

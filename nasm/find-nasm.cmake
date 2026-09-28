include_guard()

# Resolve every tool in one call, as toolchain files are re-evaluated with an
# empty cache for each `try_compile()`.
function(find_nasm_runtime)
  if(DEFINED CACHE{nasm})
    return()
  endif()

  find_program(node NAMES node)

  if(NOT node)
    message(FATAL_ERROR "Cannot find 'node', which is needed to resolve 'nasm-runtime'")
  endif()

  execute_process(
    COMMAND "${node}" "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/resolve.js" ${ARGV}
    OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE status
    ERROR_VARIABLE error
    ERROR_STRIP_TRAILING_WHITESPACE
  )

  if(NOT status EQUAL 0)
    message(FATAL_ERROR
      "Cannot resolve 'nasm-runtime': ${error}\n"
      "'cmake-toolchains' declares 'nasm-runtime' as a peer dependency and "
      "needs it to provide the assembler. Install a version of it that "
      "satisfies the peer dependency range.\n"
    )
  endif()

  string(REPLACE "\n" ";" entries "${output}")

  foreach(entry IN LISTS entries)
    if(NOT entry MATCHES "^([^=]+)=(.+)$")
      message(FATAL_ERROR "Cannot parse '${entry}' as a tool path")
    endif()

    set(${CMAKE_MATCH_1} "${CMAKE_MATCH_2}" CACHE FILEPATH "Path to ${CMAKE_MATCH_1}")
  endforeach()
endfunction()

find_nasm_runtime(nasm)

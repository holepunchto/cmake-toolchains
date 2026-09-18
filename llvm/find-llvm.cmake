include_guard()

# Resolve every tool in one call, as toolchain files are re-evaluated with an
# empty cache for each `try_compile()`.
function(find_llvm_runtime)
  if(DEFINED CACHE{llvm_resource_dir})
    return()
  endif()

  find_program(node NAMES node)

  if(NOT node)
    message(FATAL_ERROR "Cannot find 'node', which is needed to resolve 'llvm-runtime'")
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
      "Cannot resolve 'llvm-runtime': ${error}\n"
      "'cmake-toolchains' declares 'llvm-runtime' as a peer dependency and "
      "needs it to provide the toolchain. Install a version of it that "
      "satisfies the peer dependency range.\n"
    )
  endif()

  string(REPLACE "\n" ";" entries "${output}")

  foreach(entry IN LISTS entries)
    if(NOT entry MATCHES "^([^=]+)=(.+)$")
      message(FATAL_ERROR "Cannot parse '${entry}' as a tool path")
    endif()

    if(CMAKE_MATCH_1 STREQUAL "resource-dir")
      set(llvm_resource_dir "${CMAKE_MATCH_2}" CACHE PATH "The clang resource directory")
    else()
      set(${CMAKE_MATCH_1} "${CMAKE_MATCH_2}" CACHE FILEPATH "Path to ${CMAKE_MATCH_1}")
    endif()
  endforeach()
endfunction()

function(find_llvm_builtins compiler target result)
  if(DEFINED CACHE{${result}})
    return()
  endif()

  execute_process(
    COMMAND "${compiler}"
      "-resource-dir=${llvm_resource_dir}"
      "--target=${target}"
      --rtlib=compiler-rt
      --print-libgcc-file-name
    OUTPUT_VARIABLE path
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE status
    ERROR_VARIABLE error
    ERROR_STRIP_TRAILING_WHITESPACE
  )

  if(NOT status EQUAL 0)
    message(FATAL_ERROR "Cannot ask '${compiler}' for the compiler runtime builtins: ${error}")
  endif()

  # The driver answers with where it would look, not with what is there.
  if(NOT EXISTS "${path}")
    message(FATAL_ERROR
      "'llvm-runtime' has no compiler runtime builtins for '${target}'. The "
      "driver expects them at '${path}'.\n"
    )
  endif()

  set(${result} "${path}" CACHE FILEPATH "Path to the compiler runtime builtins")
endfunction()

# Toolchain files are evaluated more than once per configure, so appending
# unconditionally would repeat the flags.
function(append_flags_once variable flags)
  string(FIND "${${variable}}" "${flags}" position)

  if(position EQUAL -1)
    string(APPEND ${variable} " ${flags}")
  endif()

  return(PROPAGATE ${variable})
endfunction()

# The resource directory and `lld` ship in packages of their own, outside where
# the drivers would look. Windows drives the linker itself and instead names it
# through `CMAKE_LINKER_LLD`.
function(use_llvm_runtime)
  set(flags "\"-resource-dir=${llvm_resource_dir}\"")

  if(lld)
    cmake_path(GET lld PARENT_PATH directory)

    string(APPEND flags " \"-B${directory}\"")
  endif()

  set(variables)

  foreach(language IN LISTS ARGV)
    append_flags_once(CMAKE_${language}_FLAGS_INIT "${flags}")

    list(APPEND variables CMAKE_${language}_FLAGS_INIT)
  endforeach()

  return(PROPAGATE ${variables})
endfunction()

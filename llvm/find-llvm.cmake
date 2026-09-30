include_guard()

# Resolve every tool in one call, as toolchain files are re-evaluated with an
# empty cache for each `try_compile()`. A cache written before a tool was first
# requested lacks it, so any tool missing from the cache is resolved even when
# the others are not.
function(find_llvm_runtime)
  set(missing)

  foreach(tool IN LISTS ARGV)
    if(NOT DEFINED CACHE{${tool}})
      list(APPEND missing ${tool})
    endif()
  endforeach()

  if(DEFINED CACHE{llvm_resource_dir} AND NOT missing)
    return()
  endif()

  find_program(node NAMES node)

  if(NOT node)
    message(FATAL_ERROR "Cannot find 'node', which is needed to resolve 'llvm-runtime'")
  endif()

  execute_process(
    COMMAND "${node}" "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/resolve.js" ${missing}
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
    set(${variable} "${${variable}} ${flags}" PARENT_SCOPE)
  endif()
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

  foreach(language IN LISTS ARGV)
    append_flags_once(CMAKE_${language}_FLAGS_INIT "${flags}")

    set(CMAKE_${language}_FLAGS_INIT "${CMAKE_${language}_FLAGS_INIT}" PARENT_SCOPE)
  endforeach()
endfunction()

# Toolchain files are evaluated more than once per configure, so wrapping the
# launcher unconditionally would repeat the modification.
function(modify_test_environment modification)
  if(NOT modification IN_LIST CMAKE_TEST_LAUNCHER)
    set(CMAKE_TEST_LAUNCHER "${CMAKE_COMMAND}" -E env --modify "${modification}" -- ${CMAKE_TEST_LAUNCHER} PARENT_SCOPE)
  endif()
endfunction()

# The sanitizers look for a symbolizer on `PATH`, which the one from
# `llvm-runtime` is not on. Appending it leaves any symbolizer the environment
# already provides in charge.
function(use_llvm_symbolizer)
  cmake_path(GET llvm-symbolizer PARENT_PATH directory)
  cmake_path(NATIVE_PATH directory directory)

  modify_test_environment("PATH=path_list_append:${directory}")

  set(CMAKE_TEST_LAUNCHER "${CMAKE_TEST_LAUNCHER}" PARENT_SCOPE)
endfunction()

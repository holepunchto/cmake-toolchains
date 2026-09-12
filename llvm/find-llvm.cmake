include_guard()

# Resolves the requested tools from the `llvm-runtime` peer dependency and
# writes each one to a cache variable of the same name, alongside
# `llvm_resource_dir`. Failing to resolve is an error rather than a fallback to
# whatever LLVM happens to be installed, which would otherwise silently swap the
# toolchain for one this package makes no claims about.
#
# Every tool is resolved in a single invocation because toolchain files are
# re-evaluated for each `try_compile()`, which starts with an empty cache.
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

# Points the drivers at the resource directory and the linker, both of which
# ship in packages of their own and so sit outside the directory the drivers
# would otherwise search.
function(use_llvm_runtime)
  set(flags "-resource-dir=${llvm_resource_dir}")

  if(lld)
    cmake_path(GET lld PARENT_PATH directory)

    string(APPEND flags " -B${directory}")
  endif()

  set(variables)

  # Toolchain files are evaluated more than once per configure, so only append
  # what is not already there.
  foreach(language IN LISTS ARGV)
    string(FIND "${CMAKE_${language}_FLAGS_INIT}" "${flags}" position)

    if(position EQUAL -1)
      string(APPEND CMAKE_${language}_FLAGS_INIT " ${flags}")
    endif()

    list(APPEND variables CMAKE_${language}_FLAGS_INIT)
  endforeach()

  return(PROPAGATE ${variables})
endfunction()

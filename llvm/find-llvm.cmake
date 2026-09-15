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

# Asks the driver where the compiler runtime builtins are and writes the answer
# to a cache variable. Where CMake drives the linker directly rather than going
# through the compiler, nothing adds them to a link, and a static library that
# calls into them carries no record of the dependency.
#
# The driver is asked rather than told, because the answer moves with the
# resource directory and with however compiler-rt happens to name and lay out
# its libraries.
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

  # The driver answers with where it would look, whether or not anything is
  # there, so a target the runtime libraries were not built for only shows up
  # as a missing file at link time.
  if(NOT EXISTS "${path}")
    message(FATAL_ERROR
      "'llvm-runtime' has no compiler runtime builtins for '${target}'. The "
      "driver expects them at '${path}'.\n"
    )
  endif()

  set(${result} "${path}" CACHE FILEPATH "Path to the compiler runtime builtins")
endfunction()

# Points the drivers at the resource directory, which ships in a package of its
# own and so sits outside the directory they would otherwise search. `lld` gets
# the same treatment wherever the driver invokes it, which is everywhere the
# `-B` search path exists; Windows drives the linker directly and names it
# through `CMAKE_LINKER_LLD` instead.
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

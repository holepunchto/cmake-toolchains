include_guard()

function(find_musl_sysroot target result)
  if(DEFINED CACHE{${result}})
    return()
  endif()

  find_program(node NAMES node)

  if(NOT node)
    message(FATAL_ERROR "Cannot find 'node', which is needed to resolve 'musl-sysroot'")
  endif()

  execute_process(
    COMMAND "${node}" "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/resolve.js" "${target}"
    OUTPUT_VARIABLE path
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE status
    ERROR_VARIABLE error
    ERROR_STRIP_TRAILING_WHITESPACE
  )

  if(NOT status EQUAL 0)
    message(FATAL_ERROR
      "Cannot resolve 'musl-sysroot': ${error}\n"
      "'cmake-toolchains' declares 'musl-sysroot' as an optional peer "
      "dependency and needs it to target musl. Install a version of it that "
      "satisfies the peer dependency range.\n"
    )
  endif()

  set(${result} "${path}" CACHE PATH "The musl sysroot for ${target}")
endfunction()

# The driver links the GNU runtimes on Linux unless told otherwise, and the
# sysroot carries the LLVM ones instead.
function(use_musl_runtime)
  foreach(type IN ITEMS EXE SHARED MODULE)
    append_flags_once(CMAKE_${type}_LINKER_FLAGS_INIT "--rtlib=compiler-rt --unwindlib=libunwind")

    set(CMAKE_${type}_LINKER_FLAGS_INIT "${CMAKE_${type}_LINKER_FLAGS_INIT}" PARENT_SCOPE)
  endforeach()

  append_flags_once(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")

  set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT}" PARENT_SCOPE)
endfunction()

include_guard()

include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang clang++ clang-scan-deps llvm-ar llvm-ranlib lld)

use_llvm_runtime(C CXX ASM)

function(find_wasi_sysroot target result)
  if(DEFINED CACHE{${result}})
    return()
  endif()

  find_program(node NAMES node)

  if(NOT node)
    message(FATAL_ERROR "Cannot find 'node', which is needed to resolve 'wasi-sysroot'")
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
      "Cannot resolve 'wasi-sysroot': ${error}\n"
      "'cmake-toolchains' declares 'wasi-sysroot' as an optional peer "
      "dependency and needs it to target WASI. Install a version of it that "
      "satisfies the peer dependency range.\n"
    )
  endif()

  set(${result} "${path}" CACHE PATH "The WASI sysroot for ${target}")
endfunction()

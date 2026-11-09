include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang clang++ clang-scan-deps llvm-ar llvm-ranlib lld)

use_llvm_runtime(C CXX ASM)

set(CMAKE_AR "${llvm-ar}")
set(CMAKE_RANLIB "${llvm-ranlib}")

# CMake knows no FreeRTOS platform, so the module that defines it is put where
# `project()` looks for one.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)

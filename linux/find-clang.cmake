include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang clang++ clang-scan-deps llvm-ar llvm-ranlib lld llvm-symbolizer)

use_llvm_runtime(C CXX ASM)

use_llvm_symbolizer()

set(CMAKE_AR "${llvm-ar}")
set(CMAKE_RANLIB "${llvm-ranlib}")

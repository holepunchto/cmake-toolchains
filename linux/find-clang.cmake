include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang clang++ clang-scan-deps lld llvm-symbolizer)

use_llvm_runtime(C CXX ASM)

use_llvm_symbolizer()

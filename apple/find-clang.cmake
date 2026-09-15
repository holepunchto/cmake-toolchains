include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang clang++ clang-scan-deps)

use_llvm_runtime(C CXX ASM OBJC OBJCXX)

list(APPEND CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/use-sanitizers.cmake")

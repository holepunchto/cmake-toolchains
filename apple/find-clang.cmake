include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang clang++ clang-scan-deps llvm-symbolizer)

use_llvm_runtime(C CXX ASM OBJC OBJCXX)

use_llvm_symbolizer()

list(APPEND CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/use-sanitizers.cmake")

list(REMOVE_DUPLICATES CMAKE_PROJECT_INCLUDE)

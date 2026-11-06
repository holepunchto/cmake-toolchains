include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

# Apple platforms link with the system linker, but `lld` is resolved all the
# same so that builds that also target bare metal from the host find it.
find_llvm_runtime(clang clang++ clang-scan-deps llvm-ar llvm-ranlib llvm-symbolizer lld)

use_llvm_runtime(C CXX ASM OBJC OBJCXX)

use_llvm_symbolizer()

set(CMAKE_AR "${llvm-ar}")
set(CMAKE_RANLIB "${llvm-ranlib}")

list(APPEND CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/use-sanitizers.cmake")

list(REMOVE_DUPLICATES CMAKE_PROJECT_INCLUDE)

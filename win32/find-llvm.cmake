include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang-cl llvm-lib llvm-nm llvm-objdump llvm-ranlib llvm-rc llvm-strip lld)

use_llvm_runtime(C CXX ASM)

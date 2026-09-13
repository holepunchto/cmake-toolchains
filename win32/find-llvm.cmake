include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

find_llvm_runtime(clang-cl llvm-lib llvm-nm llvm-objdump llvm-ranlib llvm-rc llvm-strip lld-link)

# On Windows the linker is invoked directly rather than through the driver, so
# `CMAKE_LINKER_TYPE` resolves to a path instead of `-fuse-ld=`. Naming the one
# from `llvm-runtime` is what keeps it from finding a system LLVM, and clang-cl
# has no `-B` to point at its sibling package with.
if(lld-link)
  set(CMAKE_LINKER_LLD "${lld-link}")
endif()

use_llvm_runtime(C CXX ASM)

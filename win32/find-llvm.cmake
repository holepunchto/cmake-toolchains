include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

# CMake drives the linker, the manifest tool and the MASM assembler itself
# rather than through the compiler driver, so each has to be named here.
find_llvm_runtime(clang-cl llvm-lib llvm-ml64 llvm-mt llvm-nm llvm-objdump llvm-ranlib llvm-rc llvm-strip lld-link)

use_llvm_runtime(C CXX ASM)

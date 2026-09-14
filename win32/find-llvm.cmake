include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

# Windows drives the linker and the manifest tool directly rather than through
# the compiler driver, so both are named here rather than left to CMake, which
# searches the path and would find a system LLVM or, for the manifest tool,
# nothing at all outside a developer command prompt.
find_llvm_runtime(clang-cl llvm-lib llvm-mt llvm-nm llvm-objdump llvm-ranlib llvm-rc llvm-strip lld-link)

use_llvm_runtime(C CXX ASM)

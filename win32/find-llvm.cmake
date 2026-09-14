include("${CMAKE_CURRENT_LIST_DIR}/../llvm/find-llvm.cmake")

# Windows drives the linker, the manifest tool and the MASM assembler directly
# rather than through the compiler driver, so each is named here rather than
# left to CMake, which searches the path and would find a system LLVM or, for
# the latter two, nothing at all outside a developer command prompt.
#
# They are resolved together because `find_llvm_runtime()` answers only the
# first call, which is what keeps a `try_compile()` from paying for its own.
find_llvm_runtime(clang-cl llvm-lib llvm-ml64 llvm-mt llvm-nm llvm-objdump llvm-ranlib llvm-rc llvm-strip lld-link)

use_llvm_runtime(C CXX ASM)

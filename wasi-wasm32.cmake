set(CMAKE_SYSTEM_NAME WASI)
set(CMAKE_SYSTEM_PROCESSOR wasm32)

include("${CMAKE_CURRENT_LIST_DIR}/wasi/find-wasi.cmake")

set(target wasm32-wasip1)

find_llvm_builtins("${clang}" "${target}" llvm_builtins)

find_wasi_sysroot("${target}" wasi_sysroot)

set(CMAKE_SYSROOT "${wasi_sysroot}")

set(CMAKE_AR "${llvm-ar}")
set(CMAKE_RANLIB "${llvm-ranlib}")

set(CMAKE_C_COMPILER "${clang}")
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER "${clang++}")
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${clang-scan-deps}")

set(CMAKE_ASM_COMPILER "${clang}")
set(CMAKE_ASM_COMPILER_TARGET ${target})

# CMake resets `CMAKE_EXECUTABLE_SUFFIX` after reading the toolchain file, but
# leaves the per-language suffixes alone.
foreach(language IN ITEMS ASM C CXX)
  set(CMAKE_EXECUTABLE_SUFFIX_${language} ".wasm")
endforeach()

# C++ exceptions and `setjmp()` both lower to the WebAssembly exception handling
# instructions, which are on so that code behaves as it does on every other
# target. The driver picks the C++ libraries built with them, but leaves out
# the unwinder they need and the `setjmp()` runtime of wasi-libc.
set(eh_flags "-fwasm-exceptions -mllvm -wasm-use-legacy-eh=false -mllvm -wasm-enable-sjlj")

foreach(language IN ITEMS C CXX)
  append_flags_once(CMAKE_${language}_FLAGS_INIT "${eh_flags}")
endforeach()

set(CMAKE_C_STANDARD_LIBRARIES_INIT "-lsetjmp")
set(CMAKE_CXX_STANDARD_LIBRARIES_INIT "-lsetjmp -lunwind")

list(APPEND CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/wasi/no-shared-libraries.cmake")

list(REMOVE_DUPLICATES CMAKE_PROJECT_INCLUDE)

include("${CMAKE_CURRENT_LIST_DIR}/external-project/use-toolchain.cmake")

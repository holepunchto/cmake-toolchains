set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

include("${CMAKE_CURRENT_LIST_DIR}/linux/find-clang.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/musl/find-musl.cmake")

set(target arm-linux-musleabi)

find_llvm_builtins("${clang}" "${target}" llvm_builtins)

find_musl_sysroot("${target}" musl_sysroot)

set(CMAKE_SYSROOT "${musl_sysroot}")

set(CMAKE_LINKER_TYPE LLD)

set(CMAKE_C_COMPILER "${clang}")
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER "${clang++}")
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${clang-scan-deps}")

set(CMAKE_ASM_COMPILER "${clang}")
set(CMAKE_ASM_COMPILER_TARGET ${target})

foreach(language IN ITEMS ASM C CXX)
  append_flags_once(CMAKE_${language}_FLAGS_INIT -march=armv7-a)
endforeach()

set(CMAKE_EXE_LINKER_FLAGS_INIT "-static")

use_musl_runtime()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(VCPKG_TARGET_TRIPLET arm-linux-musl)

add_compile_definitions(__MUSL__)

include("${CMAKE_CURRENT_LIST_DIR}/external-project/use-toolchain.cmake")

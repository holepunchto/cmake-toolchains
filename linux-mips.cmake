set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips)

include("${CMAKE_CURRENT_LIST_DIR}/linux/find-clang.cmake")

set(target mips-linux-gnu)

set(CMAKE_LINKER_TYPE LLD)

set(CMAKE_C_COMPILER "${clang}")
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER "${clang++}")
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${clang-scan-deps}")

set(CMAKE_ASM_COMPILER "${clang}")
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(CMAKE_EXE_LINKER_FLAGS_INIT "-static")

# GCC marks MIPS objects as requiring an executable stack for the kernel FPU
# emulator, and the sysroot is built that way throughout. GNU ld honours the
# marker silently; lld refuses to link unless it is asked for.
foreach(type EXE SHARED MODULE)
  append_flags_once(CMAKE_${type}_LINKER_FLAGS_INIT -Wl,-z,execstack)
endforeach()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(VCPKG_TARGET_TRIPLET mips-linux)

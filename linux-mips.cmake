set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips)

include("${CMAKE_CURRENT_LIST_DIR}/linux/find-clang.cmake")

set(target mips-linux-gnu)

set(CMAKE_LINKER_TYPE LLD)

set(CMAKE_C_COMPILER ${clang})
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER ${clang++})
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS ${clang-scan-deps})

set(CMAKE_ASM_COMPILER ${clang})
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(CMAKE_EXE_LINKER_FLAGS_INIT "-static")

# GCC marks MIPS objects as requiring an executable stack, because the kernel
# FPU emulator executes instructions out of line on the stack to handle the
# delay slots of FPU branches, and the sysroot these targets link against is
# built that way throughout. GNU ld honours the marker silently; lld refuses to
# link unless the stack is asked for here.
foreach(type EXE SHARED MODULE)
  string(APPEND CMAKE_${type}_LINKER_FLAGS_INIT " -Wl,-z,execstack")
endforeach()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(VCPKG_TARGET_TRIPLET mips-linux)

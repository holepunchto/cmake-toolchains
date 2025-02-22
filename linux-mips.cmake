set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips)

find_program(
  clang
  NAMES clang-20 clang-19 clang-18 clang
  REQUIRED
)

find_program(
  clang++
  NAMES clang++-20 clang++-19 clang++-18 clang++
  REQUIRED
)

set(target mips-linux-gnu)

set(CMAKE_LINKER_TYPE LLD)

set(CMAKE_C_COMPILER ${clang})
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER ${clang++})
set(CMAKE_CXX_COMPILER_TARGET ${target})

set(CMAKE_ASM_COMPILER ${clang})
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(CMAKE_EXE_LINKER_FLAGS_INIT "-static")

set(VCPKG_TARGET_TRIPLET mips-linux)

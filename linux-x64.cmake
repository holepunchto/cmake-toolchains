set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

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

find_program(nasm nasm)

set(target x86_64-linux-gnu)

set(CMAKE_LINKER_TYPE LLD)

set(CMAKE_C_COMPILER ${clang})
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER ${clang++})
set(CMAKE_CXX_COMPILER_TARGET ${target})

set(CMAKE_ASM_COMPILER ${clang})
set(CMAKE_ASM_COMPILER_TARGET ${target})

if(nasm)
  set(CMAKE_ASM_NASM_COMPILER ${nasm})
endif()

set(VCPKG_TARGET_TRIPLET x64-linux)

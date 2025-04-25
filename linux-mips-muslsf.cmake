set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips)

find_program(
  cc
  NAMES mips-linux-muslsf-cc
  REQUIRED
)

find_program(
  c++
  NAMES mips-linux-muslsf-c++
  REQUIRED
)

set(target mips-linux-muslsf)

set(CMAKE_C_COMPILER ${cc})
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER ${c++})
set(CMAKE_CXX_COMPILER_TARGET ${target})

set(CMAKE_ASM_COMPILER ${cc})
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(CMAKE_EXE_LINKER_FLAGS_INIT "-static")

set(VCPKG_TARGET_TRIPLET mips-linux-muslsf)

add_compile_definitions(__MUSL__)

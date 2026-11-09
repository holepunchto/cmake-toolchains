set(CMAKE_SYSTEM_NAME FreeRTOS)
set(CMAKE_SYSTEM_PROCESSOR riscv32)

include("${CMAKE_CURRENT_LIST_DIR}/freertos/find-clang.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/picolibc/find-picolibc.cmake")

set(target riscv32-unknown-none-elf)

find_llvm_builtins("${clang}" "${target}" llvm_builtins)

find_picolibc_sysroot("${target}" picolibc_sysroot)

set(CMAKE_SYSROOT "${picolibc_sysroot}")

set(CMAKE_LINKER_TYPE LLD)

set(CMAKE_C_COMPILER "${clang}")
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER "${clang++}")
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${clang-scan-deps}")

set(CMAKE_ASM_COMPILER "${clang}")
set(CMAKE_ASM_COMPILER_TARGET ${target})

# The driver defaults to the same `rv32imac` baseline and `ilp32` ABI, but
# leaves out the CSR and fence instructions that the FreeRTOS port for RISC-V
# relies on.
foreach(language IN ITEMS ASM C CXX)
  append_flags_once(CMAKE_${language}_FLAGS_INIT "-march=rv32imac_zicsr_zifencei -mabi=ilp32")
endforeach()

# Linking an executable takes the linker script and startup code of a board,
# which only the firmware that embeds the build has.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# No compiler predefines anything for FreeRTOS.
add_compile_definitions(__FREERTOS__)

include("${CMAKE_CURRENT_LIST_DIR}/external-project/use-toolchain.cmake")

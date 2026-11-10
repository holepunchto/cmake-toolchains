set(CMAKE_SYSTEM_NAME FreeRTOS)
set(CMAKE_SYSTEM_PROCESSOR armv8m)

include("${CMAKE_CURRENT_LIST_DIR}/freertos/find-clang.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/picolibc/find-picolibc.cmake")

set(target thumbv8m.main-none-eabihf)

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

# The driver gives Armv8-M Mainline a double precision FPU by default, but the
# Cortex-M33 has only a single precision one.
foreach(language IN ITEMS ASM C CXX)
  append_flags_once(CMAKE_${language}_FLAGS_INIT "-mfpu=fpv5-sp-d16")
endforeach()

# Executables are laid out by the linker script of the board they run on. Until
# a project passes one with `-T`, the generic one of picolibc stands in, so that
# builds that link executables of their own still succeed.
append_flags_once(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,--default-script=picolibc.ld")

# Linking an executable takes the linker script and startup code of a board,
# which only the firmware that embeds the build has.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# No compiler predefines anything for FreeRTOS.
add_compile_definitions(__FREERTOS__)

include("${CMAKE_CURRENT_LIST_DIR}/external-project/use-toolchain.cmake")

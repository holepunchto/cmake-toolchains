include_guard()

# Runs executables bare-metal under QEMU, without the FreeRTOS kernel, so that
# tests of code that doesn't need it can run in place of on a board. Semihosting
# stands in for the console, the command line and the exit status, which takes
# startup code of its own and a memory layout that fits the machine.
function(use_qemu)
  cmake_parse_arguments(PARSE_ARGV 0 ARGV "" "SYSTEM;FLASH;FLASH_SIZE;RAM;RAM_SIZE" "OPTIONS")

  find_program(qemu-system-${ARGV_SYSTEM} NAMES qemu-system-${ARGV_SYSTEM} REQUIRED)

  append_flags_once(CMAKE_EXE_LINKER_FLAGS_INIT "-nostartfiles \"${CMAKE_SYSROOT}/lib/crt0-semihost.o\" -lsemihost")

  append_flags_once(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,--defsym=__flash=${ARGV_FLASH},--defsym=__flash_size=${ARGV_FLASH_SIZE},--defsym=__ram=${ARGV_RAM},--defsym=__ram_size=${ARGV_RAM_SIZE}")

  set(CMAKE_EXE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT}" PARENT_SCOPE)

  set(CMAKE_CROSSCOMPILING_EMULATOR
    "${CMAKE_COMMAND}"
    -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/qemu-run.cmake"
    "${qemu-system-${ARGV_SYSTEM}}"
    ${ARGV_OPTIONS}
    -nographic
    -monitor none
    -serial none
    --
    PARENT_SCOPE
  )
endfunction()

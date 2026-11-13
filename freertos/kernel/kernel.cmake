# Provides the FreeRTOS kernel to a project whose tests run under QEMU, and
# runs the `main()` of every executable as a task. It is included at the end of
# the first `project()`, so that the kernel exists before anything that looks
# for it.
include_guard(GLOBAL)

include(FetchContent)

# Some ports are partly written in assembly, which the project may not enable.
enable_language(ASM)

set(FREERTOS_HEAP "${CMAKE_CURRENT_LIST_DIR}/heap.c")

add_library(freertos_config INTERFACE)

target_include_directories(freertos_config SYSTEM INTERFACE "${CMAKE_CURRENT_LIST_DIR}")

FetchContent_Declare(
  freertos_kernel
  URL https://github.com/FreeRTOS/FreeRTOS-Kernel/archive/refs/tags/V11.3.3.tar.gz
  URL_HASH SHA256=943fc56e2fe32436923b29bb5c7a92a30e6c8dfdaaf7dd53d6250aba076825ec
)

FetchContent_MakeAvailable(freertos_kernel)

add_library(freertos_qemu STATIC "${CMAKE_CURRENT_LIST_DIR}/runner.c")

target_link_libraries(freertos_qemu PUBLIC freertos_kernel)

block()
  set(executable "$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>")

  # Only executables link the runner, as a library that did would require it in
  # any export set that the library is installed with.
  link_libraries("$<BUILD_INTERFACE:$<${executable}:freertos_qemu>>")

  # Otherwise, lld would only load the runner, and with it the kernel and the
  # heap, while wrapping `main()`. That comes too late for it to define the
  # symbols that the linker script of picolibc provides in terms of each other.
  add_link_options("$<${executable}:LINKER:--wrap=main,--undefined=__wrap_main>")
endblock()

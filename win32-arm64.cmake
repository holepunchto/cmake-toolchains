set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR ARM64)

set(target arm64-pc-win32)

set(CMAKE_C_COMPILER clang-cl)
set(CMAKE_C_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER clang-cl)
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_ASM_COMPILER clang-cl)
set(CMAKE_ASM_COMPILER_TARGET ${target})

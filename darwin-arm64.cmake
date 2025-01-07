set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR arm64)

find_program(clang clang REQUIRED)
find_program(clang++ clang++ REQUIRED)

set(target arm64-apple-macosx11.0)

set(CMAKE_C_COMPILER ${clang})
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER ${clang++})
set(CMAKE_CXX_COMPILER_TARGET ${target})

set(CMAKE_ASM_COMPILER ${clang})
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(CMAKE_OBJC_COMPILER ${clang})
set(CMAKE_OBJC_COMPILER_TARGET ${target})

set(CMAKE_OSX_DEPLOYMENT_TARGET 11.0)

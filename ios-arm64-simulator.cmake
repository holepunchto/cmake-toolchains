set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR arm64)

set(CMAKE_OSX_SYSROOT iphonesimulator)

set(target arm64-apple-ios14.0-simulator)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_COMPILER_TARGET ${target})

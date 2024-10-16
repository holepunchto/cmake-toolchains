set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(target x86_64-apple-ios14.0-simulator)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_COMPILER_TARGET ${target})

set(CMAKE_OSX_SYSROOT iphonesimulator)
set(CMAKE_OSX_DEPLOYMENT_TARGET 14.0)

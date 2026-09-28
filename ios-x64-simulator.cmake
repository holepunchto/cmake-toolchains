set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

include("${CMAKE_CURRENT_LIST_DIR}/apple/find-clang.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/nasm/find-nasm.cmake")

set(target x86_64-apple-ios15.0-simulator)

set(CMAKE_C_COMPILER "${clang}")
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER "${clang++}")
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${clang-scan-deps}")

set(CMAKE_ASM_COMPILER "${clang}")
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(CMAKE_ASM_NASM_COMPILER "${nasm}")

set(CMAKE_OBJC_COMPILER "${clang}")
set(CMAKE_OBJC_COMPILER_TARGET ${target})

set(CMAKE_OBJCXX_COMPILER "${clang++}")
set(CMAKE_OBJCXX_COMPILER_TARGET ${target})

set(CMAKE_OSX_SYSROOT iphonesimulator)
set(CMAKE_OSX_DEPLOYMENT_TARGET 15.0)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_MACOSX_BUNDLE OFF)

set(VCPKG_TARGET_TRIPLET x64-ios-simulator)

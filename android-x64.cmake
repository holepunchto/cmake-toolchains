set(ANDROID_TOOLCHAIN clang)
set(ANDROID_ABI x86_64)
set(ANDROID_PIE ON)
set(ANDROID_ALLOW_UNDEFINED_SYMBOLS ON)

# The legacy toolchain file of the NDK names the compilers of the NDK outright,
# where the current one leaves them to the toolchain.
set(ANDROID_USE_LEGACY_TOOLCHAIN_FILE OFF)

if(NOT DEFINED ANDROID_PLATFORM)
  set(ANDROID_PLATFORM android-29)
endif()

if(NOT DEFINED ANDROID_STL)
  set(ANDROID_STL none)
endif()

if(NOT DEFINED ANDROID_NDK)
  include("${CMAKE_CURRENT_LIST_DIR}/android/find-ndk.cmake")
endif()

include("${ANDROID_NDK}/build/cmake/android.toolchain.cmake")

include("${CMAKE_CURRENT_LIST_DIR}/linux/find-clang.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/nasm/find-nasm.cmake")

set(CMAKE_C_COMPILER_TARGET x86_64-linux-android${CMAKE_SYSTEM_VERSION})

set(CMAKE_C_COMPILER "${clang}")

set(CMAKE_CXX_COMPILER "${clang++}")
set(CMAKE_CXX_COMPILER_TARGET ${CMAKE_C_COMPILER_TARGET})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${clang-scan-deps}")

set(CMAKE_ASM_COMPILER "${clang}")
set(CMAKE_ASM_COMPILER_TARGET ${CMAKE_C_COMPILER_TARGET})

set(CMAKE_ASM_NASM_COMPILER "${nasm}")

set(VCPKG_TARGET_TRIPLET x64-android)

include("${CMAKE_CURRENT_LIST_DIR}/external-project/use-toolchain.cmake")

set(ANDROID_TOOLCHAIN clang)
set(ANDROID_ABI armeabi-v7a)
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

set(target armv7a-linux-androideabi${CMAKE_SYSTEM_VERSION})

set(CMAKE_C_COMPILER "${clang}")
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER "${clang++}")
set(CMAKE_CXX_COMPILER_TARGET ${target})
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "${clang-scan-deps}")

set(CMAKE_ASM_COMPILER "${clang}")
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(VCPKG_TARGET_TRIPLET arm-android)

include("${CMAKE_CURRENT_LIST_DIR}/external-project/use-toolchain.cmake")

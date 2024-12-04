set(ANDROID_TOOLCHAIN clang)
set(ANDROID_ABI x86_64)
set(ANDROID_PIE ON)
set(ANDROID_ALLOW_UNDEFINED_SYMBOLS ON)

if(NOT DEFINED ANDROID_PLATFORM)
  set(ANDROID_PLATFORM android-26)
endif()

if(NOT DEFINED ANDROID_STL)
  set(ANDROID_STL none)
endif()

if(NOT DEFINED ANDROID_NDK)
  include("${CMAKE_CURRENT_LIST_DIR}/android/find-ndk.cmake")
endif()

# https://github.com/android/ndk/issues/243
if(CMAKE_BUILD_TYPE MATCHES "Release")
  set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g0")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g0")
  set(CMAKE_ASM_FLAGS_RELEASE "${CMAKE_ASM_FLAGS_RELEASE} -g0")
endif()

include("${ANDROID_NDK}/build/cmake/android.toolchain.cmake")

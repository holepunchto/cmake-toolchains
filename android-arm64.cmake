set(ANDROID_TOOLCHAIN clang)
set(ANDROID_ABI arm64-v8a)
set(ANDROID_PIE ON)
set(ANDROID_ALLOW_UNDEFINED_SYMBOLS ON)

if(NOT DEFINED ANDROID_PLATFORM)
  set(ANDROID_PLATFORM android-31)
endif()

if(NOT DEFINED ANDROID_STL)
  set(ANDROID_STL c++_shared)
endif()

if(NOT DEFINED ANDROID_NDK)
  include("${CMAKE_CURRENT_LIST_DIR}/android/find-ndk.cmake")
endif()

include("${ANDROID_NDK}/build/cmake/android.toolchain.cmake")

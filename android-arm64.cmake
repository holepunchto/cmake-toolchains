set(ANDROID_TOOLCHAIN clang)
set(ANDROID_ABI arm64-v8a)
set(ANDROID_PIE ON)
set(ANDROID_ALLOW_UNDEFINED_SYMBOLS ON)

if(NOT DEFINED ANDROID_PLATFORM)
  set(ANDROID_PLATFORM android-31)
endif()

if(NOT DEFINED ANDROID_STL)
  set(ANDROID_STL none)
endif()

if(NOT DEFINED ANDROID_NDK)
  include("${CMAKE_CURRENT_LIST_DIR}/android/find-ndk.cmake")
endif()

# https://github.com/android/ndk/issues/243
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g0")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g0")
set(CMAKE_ASM_FLAGS_RELEASE "${CMAKE_ASM_FLAGS_RELEASE} -g0")

include("${ANDROID_NDK}/build/cmake/android.toolchain.cmake")

# TODO: https://gitlab.kitware.com/cmake/cmake/-/issues/26440
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE "LINKER:--whole-archive" "<LINK_ITEM>" "LINKER:--no-whole-archive")
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE_SUPPORTED TRUE)

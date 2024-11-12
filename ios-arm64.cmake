set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_SYSTEM_PROCESSOR arm64)

find_program(clang clang REQUIRED)
find_program(clang++ clang++ REQUIRED)

set(target arm64-apple-ios14.0)

set(CMAKE_C_COMPILER ${clang})
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER ${clang++})
set(CMAKE_CXX_COMPILER_TARGET ${target})

set(CMAKE_ASM_COMPILER ${clang})
set(CMAKE_ASM_COMPILER_TARGET ${target})

set(CMAKE_OBJC_COMPILER ${clang})
set(CMAKE_OBJC_COMPILER_TARGET ${target})

set(CMAKE_OSX_SYSROOT iphoneos)
set(CMAKE_OSX_DEPLOYMENT_TARGET 14.0)

# TODO: Remove when upstream bug is fixed
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE "LINKER:-force_load,<LIB_ITEM>")
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE_SUPPORTED TRUE)

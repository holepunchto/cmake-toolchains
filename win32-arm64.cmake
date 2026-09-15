set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR ARM64)

include("${CMAKE_CURRENT_LIST_DIR}/win32/find-llvm.cmake")

set(target aarch64-pc-windows-msvc)

find_llvm_builtins("${clang-cl}" "${target}" llvm_builtins)

# CMake links an MSVC target with the linker rather than the compiler, so
# nothing adds the compiler runtime builtins, and a static library that calls
# into them carries no record of the dependency.
foreach(type EXE SHARED MODULE)
  string(APPEND CMAKE_${type}_LINKER_FLAGS_INIT " \"${llvm_builtins}\"")
endforeach()

set(CMAKE_LINKER_TYPE LLD)
set(CMAKE_LINKER_LLD ${lld-link})

set(CMAKE_AR ${llvm-lib})
set(CMAKE_MT ${llvm-mt})
set(CMAKE_NM ${llvm-nm})
set(CMAKE_OBJDUMP ${llvm-objdump})
set(CMAKE_RANLIB ${llvm-ranlib})
set(CMAKE_STRIP ${llvm-strip})

set(CMAKE_C_COMPILER ${clang-cl})
set(CMAKE_C_COMPILER_TARGET ${target})

set(CMAKE_CXX_COMPILER ${clang-cl})
set(CMAKE_CXX_COMPILER_TARGET ${target})

set(CMAKE_ASM_COMPILER ${clang-cl})
set(CMAKE_ASM_COMPILER_TARGET ${target})
set(CMAKE_ASM_COMPILE_OPTIONS_MSVC_DEBUG_INFORMATION_FORMAT_Embedded -Z7)

set(CMAKE_RC_COMPILER ${llvm-rc})

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<CONFIG:Debug,RelWithDebInfo>:Embedded>")

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(VCPKG_TARGET_TRIPLET arm64-windows)

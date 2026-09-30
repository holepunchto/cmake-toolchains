include_guard()

# CMake links an MSVC target with the linker rather than the compiler, so the
# sanitizer runtimes the driver would add have to be named here. The objects
# name some runtimes themselves, but not where to find them.
#
# The flags that enable a sanitizer may come from the environment, which CMake
# only reads after the toolchain file, so both places are checked.
function(use_msvc_sanitizer_runtimes target)
  cmake_parse_arguments(PARSE_ARGV 1 ARGV "" "RUNTIME_LIBRARY" "")

  if(NOT ARGV_RUNTIME_LIBRARY)
    message(FATAL_ERROR "use_msvc_sanitizer_runtimes() needs a RUNTIME_LIBRARY variable")
  endif()

  set(directory "${llvm_resource_dir}/lib/windows")

  set(flags "\"/libpath:${directory}\"")

  if("$ENV{CFLAGS} $ENV{CXXFLAGS} ${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS}" MATCHES "[-/]fsanitize=([^ ]*,)?address([ ,]|$)")
    string(REGEX MATCH "^[^-]+" arch "${target}")

    set(runtime "${directory}/clang_rt.asan_dynamic-${arch}.lib")

    if(NOT EXISTS "${runtime}")
      message(FATAL_ERROR "'llvm-runtime' has no AddressSanitizer runtime for '${target}'")
    endif()

    string(APPEND flags " \"${runtime}\" \"/wholearchive:${directory}/clang_rt.asan_static_runtime_thunk-${arch}.lib\"")

    # The static thunk is for the static C runtime, and AddressSanitizer does
    # not support the debug one.
    set(${ARGV_RUNTIME_LIBRARY} MultiThreaded PARENT_SCOPE)
  endif()

  foreach(type IN ITEMS EXE SHARED MODULE)
    append_flags_once(CMAKE_${type}_LINKER_FLAGS_INIT "${flags}")

    set(CMAKE_${type}_LINKER_FLAGS_INIT "${CMAKE_${type}_LINKER_FLAGS_INIT}" PARENT_SCOPE)
  endforeach()
endfunction()

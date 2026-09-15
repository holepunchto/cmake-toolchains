include_guard(GLOBAL)

# Names the sanitizer runtimes on the link ahead of the libraries of a target.
#
# Apple's libSystem re-exports part of the sanitizer interfaces by way of
# `libsystem_sanitizers.dylib`, and libpthread and libm are in turn re-export
# stubs for libSystem. As CMake lists the libraries of a target ahead of the
# runtime that the driver appends, linking any of those stubs binds the shared
# symbols to Apple's implementation rather than to the runtime the program
# actually loads, which then answers with state it never initialized.
#
# The driver is asked what it would link rather than the flags being read for a
# sanitizer, because it is the driver that decides what any given `-fsanitize`
# amounts to, and its answer names the runtimes for the target being built for.
# This runs as the last step of `project()`, which is the first point at which
# the flags of the languages have been assembled and so can be asked about.
function(use_apple_sanitizer_runtimes)
  # Either language will do, as the sanitizers of a build are not language
  # specific, but only one of them is enabled in some projects. The toolchain
  # names a compiler for both regardless, so ask which are in use.
  get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

  if(C IN_LIST languages)
    set(language C)
    set(dialect c)
  elseif(CXX IN_LIST languages)
    set(language CXX)
    set(dialect c++)
  else()
    return()
  endif()

  separate_arguments(flags NATIVE_COMMAND "${CMAKE_${language}_FLAGS}")

  if(CMAKE_${language}_COMPILER_TARGET)
    list(APPEND flags "--target=${CMAKE_${language}_COMPILER_TARGET}")
  endif()

  execute_process(
    COMMAND "${CMAKE_${language}_COMPILER}" ${flags} "-###" -x ${dialect} /dev/null -o /dev/null
    OUTPUT_QUIET
    ERROR_VARIABLE output
    RESULT_VARIABLE status
  )

  if(NOT status EQUAL 0)
    message(WARNING
      "Cannot ask '${CMAKE_${language}_COMPILER}' what it would link. If this is a "
      "sanitized build, its symbols may bind to the stubs in libSystem.\n"
    )

    return()
  endif()

  string(REGEX MATCHALL "\"[^\"]*libclang_rt\\.[^\"]*_dynamic\\.dylib\"" runtimes "${output}")

  if(NOT runtimes)
    return()
  endif()

  list(REMOVE_DUPLICATES runtimes)
  list(JOIN runtimes " " runtimes)

  set(variables)

  foreach(type IN ITEMS EXE SHARED MODULE)
    string(PREPEND CMAKE_${type}_LINKER_FLAGS "${runtimes} ")

    list(APPEND variables CMAKE_${type}_LINKER_FLAGS)
  endforeach()

  return(PROPAGATE ${variables})
endfunction()

use_apple_sanitizer_runtimes()

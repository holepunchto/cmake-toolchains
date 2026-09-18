include_guard(GLOBAL)

# Apple's libSystem re-exports part of the sanitizer interfaces, and libpthread
# and libm are stubs for libSystem. CMake lists the libraries of a target ahead
# of the runtime the driver appends, so without naming the runtimes first the
# sanitizer symbols bind to Apple's implementation rather than to the runtime
# the program loads.
function(use_apple_sanitizer_runtimes)
  # Sanitizers are not language specific, but only one language may be enabled.
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

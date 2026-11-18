# Give every function and data object a section of its own, as the Android NDK
# does, so that linking with `--gc-sections` can remove those that are unused.
foreach(language IN ITEMS C CXX)
  append_flags_once(CMAKE_${language}_FLAGS_INIT "-ffunction-sections -fdata-sections")
endforeach()

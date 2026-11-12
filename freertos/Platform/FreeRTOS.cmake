# FreeRTOS is a kernel linked into the firmware rather than an operating system
# that programs run on, so it is a generic embedded platform by another name.
# The name is what lets projects tell it apart from other embedded targets.
include(Platform/Generic)

# The generic platform defines no linker types, so `CMAKE_LINKER_TYPE` would be
# rejected for anything that links.
foreach(language IN ITEMS ASM C CXX)
  set(CMAKE_${language}_USING_LINKER_LLD "-fuse-ld=lld")
endforeach()

# Nor does it define the `WHOLE_ARCHIVE` link feature. CMake would otherwise add
# it once it identifies the linker, which it never does, as nothing is linked
# while checking the compiler.
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE
  "LINKER:--push-state,--whole-archive"
  "<LINK_ITEM>"
  "LINKER:--pop-state"
)
set(CMAKE_LINK_LIBRARY_USING_WHOLE_ARCHIVE_SUPPORTED TRUE)
set(CMAKE_LINK_LIBRARY_WHOLE_ARCHIVE_ATTRIBUTES LIBRARY_TYPE=STATIC DEDUPLICATION=YES OVERRIDE=DEFAULT)

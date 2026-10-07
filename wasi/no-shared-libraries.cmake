# The WASI platform module that CMake ships leaves shared libraries enabled,
# which WebAssembly cannot link, so a shared library is built as a static one.
set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

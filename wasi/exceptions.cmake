# The driver drops backend options when it only links, even for LTO, so the
# compiler gets them here and the linker its own through the linker flags. The
# linker also needs the one that `-fwasm-exceptions` implies when compiling.
add_compile_options(
  "$<$<COMPILE_LANGUAGE:C,CXX>:-mllvm=-wasm-use-legacy-eh=false>"
  "$<$<COMPILE_LANGUAGE:C,CXX>:-mllvm=-wasm-enable-sjlj>"
)

add_test(
  NAME darwin_arm64
  COMMAND ${CMAKE_COMMAND} -S ${CMAKE_CURRENT_LIST_DIR}/fixtures/c -B ${CMAKE_CURRENT_LIST_DIR}/fixtures/c/build
)

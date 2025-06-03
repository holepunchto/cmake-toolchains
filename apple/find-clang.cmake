find_program(
  clang
  NAMES clang
  PATHS /opt/homebrew/opt/llvm/bin
  NO_DEFAULT_PATH
)

find_program(
  clang
  NAMES clang
  REQUIRED
)

find_program(
  clang++
  NAMES clang++
  PATHS /opt/homebrew/opt/llvm/bin
  NO_DEFAULT_PATH
)

find_program(
  clang
  NAMES clang++
  REQUIRED
)

find_program(
  clang-scan-deps
  NAMES clang-scan-deps
  PATHS /opt/homebrew/opt/llvm/bin
  NO_DEFAULT_PATH
)

find_program(
  clang-scan-deps
  NAMES clang-scan-deps
)

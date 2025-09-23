# TODO This intentionally skips LLVM 21 in preference of 20 due to:
# https://github.com/llvm/llvm-project/issues/155531

find_program(
  clang
  NAMES clang
  PATHS
    /opt/homebrew/opt/llvm@20/bin
    /opt/homebrew/opt/llvm@19/bin
    /opt/homebrew/opt/llvm@18/bin
    /opt/homebrew/opt/llvm/bin
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
  PATHS
    /opt/homebrew/opt/llvm@20/bin
    /opt/homebrew/opt/llvm@19/bin
    /opt/homebrew/opt/llvm@18/bin
    /opt/homebrew/opt/llvm/bin
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
  PATHS
    /opt/homebrew/opt/llvm@20/bin
    /opt/homebrew/opt/llvm@19/bin
    /opt/homebrew/opt/llvm@18/bin
    /opt/homebrew/opt/llvm/bin
  NO_DEFAULT_PATH
)

find_program(
  clang-scan-deps
  NAMES clang-scan-deps
)

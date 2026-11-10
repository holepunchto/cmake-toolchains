# cmake-toolchains

Clang-based CMake toolchain definitions for easy cross compilation. Every toolchain uses the compiler from [`llvm-runtime`](https://github.com/holepunchto/llvm-runtime), so the same compiler builds for every target from every host.

```
npm i cmake-toolchains
```

## Usage

```js
const toolchains = require('cmake-toolchains')

toolchains['linux-arm64']
// /path/to/node_modules/cmake-toolchains/linux-arm64.cmake
```

Pass the path of a toolchain file to CMake when configuring a build:

```
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=node_modules/cmake-toolchains/linux-arm64.cmake
```

Projects that are added with `ExternalProject_Add()` are configured with the same toolchain, unless they name a toolchain or compiler of their own.

### Host toolchain

A build that also compiles tools to run on the build host can find the package to get the toolchain file of the host:

```cmake
find_package(cmake-toolchains REQUIRED PATHS node_modules/cmake-toolchains)
```

This writes the path of the host toolchain file to the `CMAKE_HOST_TOOLCHAIN_FILE` cache variable.

## Toolchains

| Platform | Variant          | Toolchains                                                                                                        |
| :------- | :--------------- | :---------------------------------------------------------------------------------------------------------------- |
| Android  |                  | `android-arm`, `android-arm64`, `android-ia32`, `android-x64`                                                     |
| macOS    |                  | `darwin-arm64`, `darwin-x64`                                                                                      |
| iOS      |                  | `ios-arm64`                                                                                                       |
| iOS      | Simulator        | `ios-arm64-simulator`, `ios-x64-simulator`                                                                        |
| Linux    | glibc            | `linux-arm`, `linux-arm64`, `linux-ia32`, `linux-mips`, `linux-mipsel`, `linux-riscv64`, `linux-x64`              |
| Linux    | musl             | `linux-arm-musl`, `linux-arm64-musl`, `linux-ia32-musl`, `linux-mips-musl`, `linux-mipsel-musl`, `linux-x64-musl` |
| Linux    | musl, soft float | `linux-mips-muslsf`, `linux-mipsel-muslsf`                                                                        |
| Windows  | MSVC             | `win32-arm64`, `win32-x64`                                                                                        |
| Windows  | MinGW            | `mingw-arm64`, `mingw-x64`                                                                                        |
| WASI     |                  | `wasi-wasm32`                                                                                                     |
| FreeRTOS |                  | `freertos-armv8m`, `freertos-riscv32`                                                                             |

## Requirements

The toolchains resolve their tools from peer dependencies, which must be installed alongside `cmake-toolchains`:

- [`llvm-runtime`](https://github.com/holepunchto/llvm-runtime) for the compiler and linker. Node.js must be available to resolve it.
- [`nasm-runtime`](https://github.com/holepunchto/nasm-runtime) for the assembler on x64 and ia32 targets.
- [`musl-sysroot`](https://github.com/holepunchto/musl-sysroot) for the musl targets.
- [`wasi-sysroot`](https://github.com/holepunchto/wasi-sysroot) for the WASI target.
- [`picolibc-sysroot`](https://github.com/holepunchto/picolibc-sysroot) for the FreeRTOS targets.

The Android toolchains also need an Android NDK, which is found through the `ANDROID_HOME` environment variable. The macOS and iOS toolchains need the Apple SDKs that ship with Xcode.

## License

Apache-2.0

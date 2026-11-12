const { archive, compile, output, reconfigure, sanitize, suppress } = require('./test/helpers')

for (const fixture of ['test/fixtures/c/static-library', 'test/fixtures/cxx/static-library']) {
  compile(fixture)
}

compile('test/fixtures/c/executable')

// Linking a whole archive takes a link feature that CMake only defines once it
// identifies the linker, which it doesn't for FreeRTOS and WASI.
compile('test/fixtures/c/whole-archive')

// There is no C++ standard library for FreeRTOS yet.
compile('test/fixtures/cxx/executable', {
  targets: [
    'android-arm',
    'android-arm64',
    'android-ia32',
    'android-x64',
    'darwin-arm64',
    'darwin-x64',
    'ios-arm64',
    'ios-arm64-simulator',
    'ios-x64-simulator',
    'linux-arm',
    'linux-arm-musl',
    'linux-arm64',
    'linux-arm64-musl',
    'linux-ia32',
    'linux-ia32-musl',
    'linux-mips',
    'linux-mips-musl',
    'linux-mips-muslsf',
    'linux-mipsel',
    'linux-mipsel-musl',
    'linux-mipsel-muslsf',
    'linux-riscv64',
    'linux-x64',
    'linux-x64-musl',
    'mingw-arm64',
    'mingw-x64',
    'wasi-wasm32',
    'watchos-arm64',
    'watchos-arm64-32',
    'watchos-arm64-simulator',
    'watchos-x64-simulator',
    'win32-arm64',
    'win32-x64'
  ]
})

// The linker script of a board replaces the generic one of picolibc, which two
// sets of memory regions would otherwise conflict over.
compile('test/fixtures/freertos/linker-script', {
  targets: ['freertos-armv8m', 'freertos-riscv32']
})

// WebAssembly and FreeRTOS have no shared libraries.
for (const fixture of ['test/fixtures/c/shared-library', 'test/fixtures/cxx/shared-library']) {
  compile(fixture, {
    targets: [
      'android-arm',
      'android-arm64',
      'android-ia32',
      'android-x64',
      'darwin-arm64',
      'darwin-x64',
      'ios-arm64',
      'ios-arm64-simulator',
      'ios-x64-simulator',
      'linux-arm',
      'linux-arm-musl',
      'linux-arm64',
      'linux-arm64-musl',
      'linux-ia32',
      'linux-ia32-musl',
      'linux-mips',
      'linux-mips-musl',
      'linux-mips-muslsf',
      'linux-mipsel',
      'linux-mipsel-musl',
      'linux-mipsel-muslsf',
      'linux-riscv64',
      'linux-x64',
      'linux-x64-musl',
      'mingw-arm64',
      'mingw-x64',
      'watchos-arm64',
      'watchos-arm64-32',
      'watchos-arm64-simulator',
      'watchos-x64-simulator',
      'win32-arm64',
      'win32-x64'
    ]
  })
}

// WebAssembly executables take the `.wasm` suffix in every language.
for (const fixture of ['test/fixtures/c/executable', 'test/fixtures/cxx/executable']) {
  output(fixture, 'exe.wasm', { targets: ['wasi-wasm32'] })
}

// Static executables link the static libraries of the sysroot, whose debug
// sections may be compressed, as those of the NDK are with zstd. Apple
// platforms have no static executables, and Windows selects a static C runtime
// rather than linking with `-static`.
compile('test/fixtures/c/static-executable', {
  targets: [
    'android-arm',
    'android-arm64',
    'android-ia32',
    'android-x64',
    'linux-arm',
    'linux-arm-musl',
    'linux-arm64',
    'linux-arm64-musl',
    'linux-ia32',
    'linux-ia32-musl',
    'linux-mips',
    'linux-mips-musl',
    'linux-mips-muslsf',
    'linux-mipsel',
    'linux-mipsel-musl',
    'linux-mipsel-muslsf',
    'linux-riscv64',
    'linux-x64',
    'linux-x64-musl',
    'wasi-wasm32'
  ]
})

// Subprojects added with `ExternalProject_Add()` inherit the toolchain, unless
// the caller names a compiler of its own.
compile('test/fixtures/external-project')
compile('test/fixtures/external-project-compiler')

// Archives of LTO objects hold bitcode, which only an archiver that matches the
// compiler can index.
archive('test/fixtures/lto', {
  targets: [
    'android-arm',
    'android-arm64',
    'android-ia32',
    'android-x64',
    'darwin-arm64',
    'darwin-x64',
    'freertos-armv8m',
    'freertos-riscv32',
    'ios-arm64',
    'ios-arm64-simulator',
    'ios-x64-simulator',
    'linux-arm',
    'linux-arm-musl',
    'linux-arm64',
    'linux-arm64-musl',
    'linux-ia32',
    'linux-ia32-musl',
    'linux-mips',
    'linux-mips-musl',
    'linux-mips-muslsf',
    'linux-mipsel',
    'linux-mipsel-musl',
    'linux-mipsel-muslsf',
    'linux-riscv64',
    'linux-x64',
    'linux-x64-musl',
    'watchos-arm64',
    'watchos-arm64-32',
    'watchos-arm64-simulator',
    'watchos-x64-simulator'
  ]
})

// Objective-C only exists on the Apple platforms.
for (const fixture of ['test/fixtures/objc/executable', 'test/fixtures/objcxx/executable']) {
  compile(fixture, {
    targets: [
      'darwin-arm64',
      'darwin-x64',
      'ios-arm64',
      'ios-arm64-simulator',
      'ios-x64-simulator',
      'watchos-arm64',
      'watchos-arm64-32',
      'watchos-arm64-simulator',
      'watchos-x64-simulator'
    ]
  })
}

// NASM is only provided by the x86 toolchains.
for (const fixture of [
  'test/fixtures/nasm/executable',
  'test/fixtures/nasm/shared-library',
  'test/fixtures/nasm/static-library'
]) {
  compile(fixture, {
    targets: [
      'android-ia32',
      'android-x64',
      'darwin-x64',
      'ios-x64-simulator',
      'linux-ia32',
      'linux-ia32-musl',
      'linux-x64',
      'linux-x64-musl',
      'watchos-x64-simulator',
      'win32-x64'
    ]
  })
}

// Sanitizers only exist where `llvm-runtime` ships their runtimes.
const sanitized = [
  'darwin-arm64',
  'darwin-x64',
  'ios-arm64',
  'ios-arm64-simulator',
  'ios-x64-simulator',
  'linux-arm64',
  'linux-ia32',
  'linux-riscv64',
  'linux-x64',
  'win32-x64'
]

sanitize('test/fixtures/sanitize/address', 'address', {
  targets: sanitized,
  report: /AddressSanitizer: heap-buffer-overflow/,
  symbolized: true
})

sanitize('test/fixtures/sanitize/undefined', 'undefined', {
  targets: sanitized,
  report: /runtime error: signed integer overflow/
})

// LeakSanitizer only exists on Linux and macOS. Suppressions match against the
// symbolized stack, so a missing symbolizer leaves the leak unsuppressed.
suppress('test/fixtures/sanitize/leak', {
  targets: [
    'darwin-arm64',
    'darwin-x64',
    'linux-arm64',
    'linux-ia32',
    'linux-riscv64',
    'linux-x64'
  ],
  report: /LeakSanitizer: detected memory leaks[^]*in leak_memory/
})

// Every toolchain that uses `llvm-runtime` asks it for the symbolizer.
reconfigure('test/fixtures/c/executable', 'llvm-symbolizer', {
  targets: [
    'android-arm',
    'android-arm64',
    'android-ia32',
    'android-x64',
    'darwin-arm64',
    'darwin-x64',
    'ios-arm64',
    'ios-arm64-simulator',
    'ios-x64-simulator',
    'linux-arm',
    'linux-arm-musl',
    'linux-arm64',
    'linux-arm64-musl',
    'linux-ia32',
    'linux-ia32-musl',
    'linux-mips',
    'linux-mips-musl',
    'linux-mips-muslsf',
    'linux-mipsel',
    'linux-mipsel-musl',
    'linux-mipsel-muslsf',
    'linux-riscv64',
    'linux-x64',
    'linux-x64-musl',
    'watchos-arm64',
    'watchos-arm64-32',
    'watchos-arm64-simulator',
    'watchos-x64-simulator',
    'win32-arm64',
    'win32-x64'
  ]
})

// The Android, Apple, FreeRTOS, and Linux toolchains ask `llvm-runtime` for the
// archiver.
for (const tool of ['llvm-ar', 'llvm-ranlib']) {
  reconfigure('test/fixtures/c/static-library', tool, {
    targets: [
      'android-arm',
      'android-arm64',
      'android-ia32',
      'android-x64',
      'darwin-arm64',
      'darwin-x64',
      'freertos-armv8m',
      'freertos-riscv32',
      'ios-arm64',
      'ios-arm64-simulator',
      'ios-x64-simulator',
      'linux-arm',
      'linux-arm-musl',
      'linux-arm64',
      'linux-arm64-musl',
      'linux-ia32',
      'linux-ia32-musl',
      'linux-mips',
      'linux-mips-musl',
      'linux-mips-muslsf',
      'linux-mipsel',
      'linux-mipsel-musl',
      'linux-mipsel-muslsf',
      'linux-riscv64',
      'linux-x64',
      'linux-x64-musl',
      'watchos-arm64',
      'watchos-arm64-32',
      'watchos-arm64-simulator',
      'watchos-x64-simulator'
    ]
  })
}

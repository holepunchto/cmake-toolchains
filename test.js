const { compile, reconfigure, sanitize, suppress } = require('./test/helpers')

for (const fixture of [
  'test/fixtures/c/executable',
  'test/fixtures/c/shared-library',
  'test/fixtures/c/static-library',
  'test/fixtures/cxx/executable',
  'test/fixtures/cxx/shared-library',
  'test/fixtures/cxx/static-library'
]) {
  compile(fixture)
}

// Subprojects added with `ExternalProject_Add()` inherit the toolchain.
compile('test/fixtures/external-project')

// Objective-C only exists on the Apple platforms.
for (const fixture of ['test/fixtures/objc/executable', 'test/fixtures/objcxx/executable']) {
  compile(fixture, {
    targets: ['darwin-arm64', 'darwin-x64', 'ios-arm64', 'ios-arm64-simulator', 'ios-x64-simulator']
  })
}

// NASM is only provided by the x86 toolchains, except those for Android.
for (const fixture of [
  'test/fixtures/nasm/executable',
  'test/fixtures/nasm/shared-library',
  'test/fixtures/nasm/static-library'
]) {
  compile(fixture, {
    targets: ['darwin-x64', 'ios-x64-simulator', 'linux-ia32', 'linux-x64', 'win32-x64']
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
    'darwin-arm64',
    'darwin-x64',
    'ios-arm64',
    'ios-arm64-simulator',
    'ios-x64-simulator',
    'linux-arm',
    'linux-arm64',
    'linux-ia32',
    'linux-mips',
    'linux-mipsel',
    'linux-riscv64',
    'linux-x64',
    'win32-arm64',
    'win32-x64'
  ]
})

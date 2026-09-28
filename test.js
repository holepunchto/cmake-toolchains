const { compile } = require('./test/helpers')

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

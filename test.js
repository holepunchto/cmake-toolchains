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

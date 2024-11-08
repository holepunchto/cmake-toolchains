const { compile } = require('./test/helpers')

for (const fixture of [
  'test/fixtures/c/executable',
  'test/fixtures/c/shared-library',
  'test/fixtures/c/static-library'
]) {
  compile(fixture)
}

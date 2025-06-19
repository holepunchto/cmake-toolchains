const { compile } = require('./test/helpers')

for (const fixture of [
  'test/fixtures/c/executable',
  'test/fixtures/c/openmp',
  'test/fixtures/c/shared-library',
  'test/fixtures/c/static-library',
  'test/fixtures/cxx/executable',
  'test/fixtures/cxx/shared-library',
  'test/fixtures/cxx/static-library'
]) {
  compile(fixture)
}

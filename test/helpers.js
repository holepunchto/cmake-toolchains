const test = require('brittle')
const fs = require('fs')
const path = require('path')
const cmake = require('cmake-runtime/spawn')
const cmakeBinary = require('cmake-runtime')()
const ctestBinary = require('cmake-runtime')('ctest')
const resourceDir = require('llvm-runtime/resource-dir')
const ninja = require('ninja-runtime')()
const NewlineDecoder = require('newline-decoder')
const { platform, arch } = require('which-runtime')
const toolchains = require('..')

for (const binary of [ninja, ctestBinary]) {
  try {
    fs.accessSync(binary, fs.constants.X_OK)
  } catch {
    fs.chmodSync(binary, 0o755)
  }
}

function print(t, stream) {
  const decoder = new NewlineDecoder()

  stream
    .on('data', (data) => {
      for (const line of decoder.push(data)) {
        t.comment(line)
      }
    })
    .on('close', () => {
      for (const line of decoder.end()) {
        t.comment(line)
      }
    })
}

function spawn(t, args) {
  const job = cmake('cmake', { args })

  let output = ''

  return new Promise((resolve) => {
    print(t, job.stdout)
    print(t, job.stderr)

    job.stdout.on('data', (data) => {
      output += data
    })

    job.stderr.on('data', (data) => {
      output += data
    })

    job.on('exit', (code) => resolve({ code, output }))
  })
}

async function run(t, args) {
  const { code } = await spawn(t, args)

  if (code !== 0) throw new Error('Failed')
}

async function generate(t, fixture, target, toolchain, opts = {}) {
  const { env = [], args = [] } = opts

  const source = path.resolve(__dirname, '..', fixture)
  const build = path.join(source, 'build', target)

  await run(t, [
    '-E',
    'env',
    ...env,
    '--',
    cmakeBinary,
    '-S',
    source,
    '-B',
    build,
    '-G',
    'Ninja',
    '--fresh',
    '--toolchain',
    toolchain,
    '-DCMAKE_MESSAGE_LOG_LEVEL=NOTICE',
    `-DCMAKE_MAKE_PROGRAM=${ninja}`,
    ...args
  ])

  await run(t, ['--build', build, '--clean-first'])

  return build
}

function skip(target) {
  switch (target) {
    case 'android-arm':
    case 'android-arm64':
    case 'android-ia32':
    case 'android-x64':
      return platform !== 'darwin'
    case 'darwin-arm64':
    case 'darwin-x64':
    case 'ios-arm64':
    case 'ios-arm64-simulator':
    case 'ios-x64-simulator':
      return platform !== 'darwin'
    case 'linux-arm':
    case 'linux-arm64':
    case 'linux-mips':
    case 'linux-mipsel':
    case 'linux-ia32':
    case 'linux-riscv64':
    case 'linux-x64':
      return platform !== 'linux'
    case 'win32-arm64':
    case 'win32-x64':
      return platform !== 'win32'
  }

  return true
}

exports.compile = function compile(fixture, opts = {}) {
  const { targets = null } = opts

  for (const [target, toolchain] of Object.entries(toolchains)) {
    if (targets !== null && targets.includes(target) === false) continue

    test(`${fixture}, ${target}`, { skip: skip(target), timeout: 120000 }, async (t) => {
      await generate(t, fixture, target, toolchain)
    })
  }
}

// Only the AddressSanitizer runtime for Windows, which is a DLL, is left on
// `PATH`. Any symbolizer the sanitizers find must then come from the toolchain.
function ctest(t, build, env = []) {
  return spawn(t, [
    '-E',
    'env',
    `PATH=${path.join(resourceDir(), 'lib', 'windows')}`,
    ...env,
    '--',
    ctestBinary,
    '--test-dir',
    build,
    '--verbose'
  ])
}

// Reported by the sanitizer runtimes at `verbosity=2`.
const symbolizer = /Using llvm-symbolizer (found )?at/

function sanitized(sanitizer) {
  const flags = `-fsanitize=${sanitizer}`

  return {
    env: [`CFLAGS=${flags}`, `CXXFLAGS=${flags}`, `LDFLAGS=${flags}`],
    args: ['-DCMAKE_BUILD_TYPE=Debug']
  }
}

exports.sanitize = function sanitize(fixture, sanitizer, opts = {}) {
  const { targets = null, report, symbolized = false } = opts

  for (const [target, toolchain] of Object.entries(toolchains)) {
    if (targets !== null && targets.includes(target) === false) continue

    test(`${fixture}, ${target}`, { skip: skip(target), timeout: 120000 }, async (t) => {
      const build = await generate(t, fixture, target, toolchain, sanitized(sanitizer))

      if (target !== `${platform}-${arch}`) return

      const { output } = await ctest(t, build, symbolized ? ['ASAN_OPTIONS=verbosity=2'] : [])

      t.ok(report.test(output), `reports ${report}`)

      if (symbolized) t.ok(symbolizer.test(output), 'uses llvm-symbolizer')
    })
  }
}

exports.suppress = function suppress(fixture, opts = {}) {
  const { targets = null, report } = opts

  const suppressions = path.resolve(__dirname, '..', fixture, 'suppressions.txt')

  for (const [target, toolchain] of Object.entries(toolchains)) {
    if (targets !== null && targets.includes(target) === false) continue

    test(`${fixture}, ${target}`, { skip: skip(target), timeout: 120000 }, async (t) => {
      const build = await generate(t, fixture, target, toolchain, sanitized('address'))

      if (target !== `${platform}-${arch}`) return

      const env = ['ASAN_OPTIONS=detect_leaks=1:verbosity=2']

      const leaked = await ctest(t, build, env)

      t.ok(report.test(leaked.output), `reports ${report}`)
      t.ok(symbolizer.test(leaked.output), 'uses llvm-symbolizer')

      const suppressed = await ctest(t, build, [
        ...env,
        `LSAN_OPTIONS=suppressions=${suppressions}`
      ])

      t.is(suppressed.code, 0, 'suppresses the leak')
    })
  }
}

// A build configured before a tool was first requested holds a cache without
// it, which removing the tool from the cache reproduces.
exports.reconfigure = function reconfigure(fixture, tool, opts = {}) {
  const { targets = null } = opts

  for (const [target, toolchain] of Object.entries(toolchains)) {
    if (targets !== null && targets.includes(target) === false) continue

    test(
      `${fixture}, ${target}, reconfigured without ${tool}`,
      { skip: skip(target), timeout: 120000 },
      async (t) => {
        const build = await generate(t, fixture, target, toolchain)

        await run(t, ['-U', tool, build])

        await run(t, ['--build', build])
      }
    )
  }
}

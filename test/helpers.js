const test = require('brittle')
const fs = require('fs')
const path = require('path')
const spawn = require('cmake-runtime/spawn')
const cmake = require('cmake-runtime')()
const ctest = require('cmake-runtime')('ctest')
const llvm = require('llvm-runtime')
const ninja = require('ninja-runtime')()
const NewlineDecoder = require('newline-decoder')
const { platform, arch } = require('which-runtime')
const toolchains = require('..')

for (const binary of [ninja, ctest]) {
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

function capture(t, args) {
  const job = spawn('cmake', { args })

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
  const { code } = await capture(t, args)

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
    cmake,
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

// With `PATH` cleared, the symbolizer and the AddressSanitizer runtime for
// Windows must come from the toolchain.
function runTests(t, build, env = []) {
  return capture(t, ['-E', 'env', 'PATH=', ...env, '--', ctest, '--test-dir', build, '--verbose'])
}

function skip(target) {
  switch (target) {
    case 'android-arm':
    case 'android-arm64':
    case 'android-ia32':
    case 'android-x64':
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

function each(targets, name, fn) {
  for (const [target, toolchain] of Object.entries(toolchains)) {
    if (targets !== null && targets.includes(target) === false) continue

    test(name(target), { skip: skip(target), timeout: 120000 }, (t) => fn(t, target, toolchain))
  }
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

exports.compile = function compile(fixture, opts = {}) {
  const { targets = null } = opts

  each(
    targets,
    (target) => `${fixture}, ${target}`,
    async (t, target, toolchain) => {
      await generate(t, fixture, target, toolchain)
    }
  )
}

// The archiver the host provides may be recent enough to read the bitcode
// either way, so check that the build asks `llvm-runtime` for it.
exports.archive = function archive(fixture, opts = {}) {
  const { targets = null } = opts

  each(
    targets,
    (target) => `${fixture}, ${target}`,
    async (t, target, toolchain) => {
      const build = await generate(t, fixture, target, toolchain)

      const rules = fs.readFileSync(path.join(build, 'CMakeFiles', 'rules.ninja'), 'utf8')

      for (const tool of ['llvm-ar', 'llvm-ranlib']) {
        t.ok(rules.includes(llvm(tool)), `archives with ${tool} from llvm-runtime`)
      }
    }
  )
}

exports.sanitize = function sanitize(fixture, sanitizer, opts = {}) {
  const { targets = null, report, symbolized = false } = opts

  each(
    targets,
    (target) => `${fixture}, ${target}`,
    async (t, target, toolchain) => {
      const build = await generate(t, fixture, target, toolchain, sanitized(sanitizer))

      if (target !== `${platform}-${arch}`) return

      const { output } = await runTests(t, build, symbolized ? ['ASAN_OPTIONS=verbosity=2'] : [])

      t.ok(report.test(output), `reports ${report}`)

      if (symbolized) t.ok(symbolizer.test(output), 'uses llvm-symbolizer')
    }
  )
}

exports.suppress = function suppress(fixture, opts = {}) {
  const { targets = null, report } = opts

  const suppressions = path.resolve(__dirname, '..', fixture, 'suppressions.txt')

  each(
    targets,
    (target) => `${fixture}, ${target}`,
    async (t, target, toolchain) => {
      const build = await generate(t, fixture, target, toolchain, sanitized('address'))

      if (target !== `${platform}-${arch}`) return

      const env = ['ASAN_OPTIONS=detect_leaks=1:verbosity=2']

      const leaked = await runTests(t, build, env)

      t.ok(report.test(leaked.output), `reports ${report}`)
      t.ok(symbolizer.test(leaked.output), 'uses llvm-symbolizer')

      const suppressed = await runTests(t, build, [
        ...env,
        `LSAN_OPTIONS=suppressions=${suppressions}`
      ])

      t.is(suppressed.code, 0, 'suppresses the leak')
    }
  )
}

// A build configured before a tool was first requested holds a cache without
// it, which removing the tool from the cache reproduces.
exports.reconfigure = function reconfigure(fixture, tool, opts = {}) {
  const { targets = null } = opts

  each(
    targets,
    (target) => `${fixture}, ${target}, reconfigured without ${tool}`,
    async (t, target, toolchain) => {
      const build = await generate(t, fixture, target, toolchain)

      await run(t, ['-U', tool, build])

      await run(t, ['--build', build])
    }
  )
}

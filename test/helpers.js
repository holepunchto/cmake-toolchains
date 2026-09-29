const test = require('brittle')
const fs = require('fs')
const path = require('path')
const cmake = require('cmake-runtime/spawn')
const cmakeBinary = require('cmake-runtime')()
const resourceDir = require('llvm-runtime/resource-dir')
const ninja = require('ninja-runtime')()
const NewlineDecoder = require('newline-decoder')
const { platform, arch } = require('which-runtime')
const toolchains = require('..')

try {
  fs.accessSync(ninja, fs.constants.X_OK)
} catch {
  fs.chmodSync(ninja, 0o755)
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

exports.sanitize = function sanitize(fixture, sanitizer, opts = {}) {
  const { targets = null, report } = opts

  for (const [target, toolchain] of Object.entries(toolchains)) {
    if (targets !== null && targets.includes(target) === false) continue

    test(`${fixture}, ${target}`, { skip: skip(target), timeout: 120000 }, async (t) => {
      const flags = `-fsanitize=${sanitizer}`

      const build = await generate(t, fixture, target, toolchain, {
        env: [`CFLAGS=${flags}`, `CXXFLAGS=${flags}`, `LDFLAGS=${flags}`],
        args: ['-DCMAKE_BUILD_TYPE=Debug']
      })

      if (target !== `${platform}-${arch}`) return

      const exe = path.join(build, platform === 'win32' ? 'exe.exe' : 'exe')

      // The AddressSanitizer runtime for Windows is a DLL.
      const { output } = await spawn(t, [
        '-E',
        'env',
        '--modify',
        `PATH=path_list_prepend:${path.join(resourceDir(), 'lib', 'windows')}`,
        '--',
        exe
      ])

      t.ok(report.test(output), `reports ${report}`)
    })
  }
}

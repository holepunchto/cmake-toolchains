const test = require('brittle')
const fs = require('fs')
const path = require('path')
const cmake = require('cmake-runtime/spawn')
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

async function run(t, referrer, args, opts = {}) {
  const job = cmake(referrer, { ...opts, args })

  await new Promise((resolve, reject) => {
    print(t, job.stdout)
    print(t, job.stderr)

    job.on('exit', (code) => {
      if (code === null || code !== 0) {
        reject(new Error('Failed'))
      } else {
        resolve()
      }
    })
  })
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
    case 'linux-arm64':
      return platform !== 'linux' || arch !== 'arm64'
    case 'linux-mips':
      return platform !== 'linux'
    case 'linux-mipsel':
      return platform !== 'linux'
    case 'linux-x64':
      return platform !== 'linux' || arch !== 'x64'
    case 'win32-arm64':
    case 'win32-x64':
      return platform !== 'win32'
  }

  return true
}

exports.compile = function compile(fixture) {
  for (const [target, toolchain] of Object.entries(toolchains)) {
    test(
      `${fixture}, ${target}`,
      { skip: skip(target), timeout: 120000 },
      async (t) => {
        const source = path.resolve(__dirname, '..', fixture)
        const build = path.join(source, 'build', target)

        await run(t, 'cmake', [
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
          `-DCMAKE_MAKE_PROGRAM=${ninja}`
        ])

        await run(t, 'cmake', ['--build', build, '--clean-first'])
      }
    )
  }
}

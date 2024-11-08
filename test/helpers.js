const test = require('brittle')
const path = require('path')
const cmake = require('cmake-runtime/spawn')
const ninja = require('ninja-runtime')()
const NewlineDecoder = require('newline-decoder')
const toolchains = require('..')

function print (t, stream) {
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

async function run (t, referrer, args, opts = {}) {
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

function skip (target) {
  const platform = process.platform
  if (target.startsWith('darwin') || target.startsWith('ios')) return platform !== 'darwin'
  if (target.startsWith('linux')) return platform !== 'linux'
  if (target.startsWith('android')) return platform !== 'darwin' && platform !== 'linux'
  if (target.startsWith('win32')) return platform !== 'win32'
  return true
}

exports.compile = async function compile (fixture) {
  for (const [target, toolchain] of Object.entries(toolchains)) {
    await test(`${fixture}, ${target}`, { skip: skip(target) }, async (t) => {
      const source = path.resolve(__dirname, '..', fixture)
      const build = path.join(source, 'build', target)

      await run(t, 'cmake', [
        '-S', source,
        '-B', build,
        '-G', 'Ninja',
        '--fresh',
        '--toolchain', toolchain,
        '-DCMAKE_MESSAGE_LOG_LEVEL=NOTICE',
        `-DCMAKE_MAKE_PROGRAM=${ninja}`
      ])

      await run(t, 'cmake', [
        '--build', build,
        '--clean-first'
      ])
    })
  }
}

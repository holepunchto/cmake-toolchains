const lines = []

// A stack trace through the module loader tells the caller nothing it can use.
try {
  const runtime = require('llvm-runtime')
  const resourceDir = require('llvm-runtime/resource-dir')

  for (const tool of process.argv.slice(2)) {
    lines.push(`${tool}=${runtime(tool)}`)
  }

  lines.push(`resource-dir=${resourceDir()}`)
} catch (err) {
  process.stderr.write(err.message.split('\n')[0] + '\n')
  process.exit(1)
}

process.stdout.write(lines.join('\n') + '\n')

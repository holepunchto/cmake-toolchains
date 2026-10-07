// A stack trace through the module loader tells the caller nothing it can use.
try {
  const sysroot = require('wasi-sysroot')

  process.stdout.write(sysroot(process.argv[2]) + '\n')
} catch (err) {
  process.stderr.write(err.message.split('\n')[0] + '\n')
  process.exit(1)
}

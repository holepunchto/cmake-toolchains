require.asset = require('require-asset')

exports['android-arm'] = require.asset('./android-arm.cmake', __filename)
exports['android-arm64'] = require.asset('./android-arm64.cmake', __filename)
exports['android-ia32'] = require.asset('./android-ia32.cmake', __filename)
exports['android-x64'] = require.asset('./android-x64.cmake', __filename)
exports['darwin-arm64'] = require.asset('./darwin-arm64.cmake', __filename)
exports['darwin-x64'] = require.asset('./darwin-x64.cmake', __filename)
exports['ios-arm64'] = require.asset('./ios-arm64.cmake', __filename)
exports['ios-arm64-simulator'] = require.asset(
  './ios-arm64-simulator.cmake',
  __filename
)
exports['ios-x64-simulator'] = require.asset(
  './ios-x64-simulator.cmake',
  __filename
)
exports['linux-arm64'] = require.asset('./linux-arm64.cmake', __filename)
exports['linux-x64'] = require.asset('./linux-x64.cmake', __filename)
exports['win32-arm64'] = require.asset('./win32-arm64.cmake', __filename)
exports['win32-x64'] = require.asset('./win32-x64.cmake', __filename)

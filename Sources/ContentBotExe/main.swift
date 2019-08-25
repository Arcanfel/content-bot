import ContentBot
import Files
import Foundation
import HeliumLogger
import LoggerAPI

Log.logger = {
  let logger = HeliumLogger()
  logger.colored = true
  return logger
}()

do {
  var configurationPath = "\(Folder.home.path)lappin/swift/content-bot/config.json"
  #if os(Linux)
    configurationPath = "\(Folder.current.path)config.json"
  #endif
  try App(withConfigurationPath: configurationPath).start()
} catch {
  print(error.localizedDescription)
}

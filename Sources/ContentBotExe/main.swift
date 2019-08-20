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
  print("nice!")
  let configurationPath = "\(Folder.home.path)lappin/swift/content-bot/config.json"
  try App(withConfigurationPath: configurationPath).start()
} catch {
  print(error.localizedDescription)
}

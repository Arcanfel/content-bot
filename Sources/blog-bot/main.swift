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
  let configurationPath = "\(Folder.home.path)lappin/swift/content-bot/\(Constants.appConfigurationFileName)"
  if let configuration = try FileImporter.appConfiguration().importFile(atPath: configurationPath) {
    _ = App(withAppConfiguration: configuration).start()
  }
} catch {
  print(error.localizedDescription)
}

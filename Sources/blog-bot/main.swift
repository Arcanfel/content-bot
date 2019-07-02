import Files
import Foundation
import HeliumLogger
import LoggerAPI

let logger = HeliumLogger()
Log.logger = logger

do {
    let configurationPath = "\(Folder.home.path)lappin/swift/content-bot/\(Constants.appConfigurationFileName)"
    if let configuration = try FileImporter.appConfiguration().importFile(atPath: configurationPath) {
        _ = ContentBot(withAppConfiguration: configuration).start()
    }
} catch {
    print(error.localizedDescription)
}

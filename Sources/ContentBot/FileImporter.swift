import Files
import Foundation

struct AppConfiguration: Decodable {
  var telegramBotToken: String
  var debug: Bool
  var twitter: Twitter

  struct Twitter: Decodable {
    var apiKey: String
    var apiSecret: String
  }
}

enum FileImportResult {
  case configuration(AppConfiguration)
}

struct FileImporter<Result> {
  typealias Handler = (File) throws -> Result?
  var handler: Handler
}

extension FileImporter {
  typealias FileType = String

  init(handlers: [FileType: Handler]) {
    handler = { file in
      guard let ext = file.extension, let fileHandler = handlers[ext] else {
        return nil
      }
      return try fileHandler(file) ?? nil
    }
  }

  func importFiles(from folder: Folder) throws -> [Result] {
    return try folder.files.compactMap(handler)
  }

  func importFile(atPath path: String) throws -> Result? {
    return try handler(File(path: path))
  }
}

extension FileImporter where Result == AppConfiguration {
  static func appConfiguration() -> FileImporter {
    return FileImporter(handlers: [
      "json": importJsonFile
    ])
  }

  private static func importJsonFile(from file: File) throws -> AppConfiguration {
    let url = URL(fileURLWithPath: file.path)
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(AppConfiguration.self, from: data)
  }
}

extension FileImporter where Result == FileImportResult {
  static func combined() -> FileImporter {
    let importers =
      FileImporter<AppConfiguration>.appConfiguration()

    return FileImporter { file in
      try importers.handler(file).map(Result.configuration)
    }
  }
}

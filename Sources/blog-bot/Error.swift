import Foundation

enum AppError: Error {
  case urlRequestFailed((URLRequest, URLResponse?))
  case failedToConstructUrl(String)

  var localizedDescription: String {
    switch self {
    case .urlRequestFailed((let request, _)):
      let method = request.httpMethod ?? ""
      let url = request.url?.absoluteString ?? ""
      return "\(method) \(url) failed with no error or data"
    case let .failedToConstructUrl(urlString):
      return "failed to construct with \(urlString)"
    }
  }
}

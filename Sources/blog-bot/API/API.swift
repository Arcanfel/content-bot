import Foundation

// Namespace
enum API {}

protocol APIClientProtocol {
  var baseUrl: String { get set }
  var session: URLSession { get set }
  var debugMode: Bool { get set }
  var headers: [(name: API.HTTPHeader, value: String)] { get }
}

protocol APIEndpoint {
  var path: String { get }
  var method: API.HTTPMethod { get }
  var params: [(value: [String: Any], encoding: API.EncodingMethod)]? { get }
  var headers: [API.HTTPHeaderField] { get }
}

protocol APIRequest {
  var path: String { get }
  var method: String { get }
}

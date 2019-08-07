import Foundation
import KituraNet
import LoggerAPI
import RxSwift

/// APIClientProtocol is an implementation of a simple http client.
/// Struct or a class which implements this protocol will need to provide
/// at least baseUrl, and a list of requestOptions (can be empty).
/// An example is a TelegramAPI client.
extension API {
  typealias HTTPHeaderField = (name: HTTPHeader, value: String)
  typealias EndpointParams = (value: [String: Any], encoding: EncodingMethod)

  enum EncodingMethod {
    case form
    case json
    case query

    func toData(params: [String: Any]) -> Data? {
      switch self {
      case .form: return params.formQueryData
      case .json: return params.jsonData
      case .query: return nil
      }
    }
  }

  enum HTTPMethod: String {
    case get
    case post
  }

  enum HTTPHeader: String {
    case accept = "Accept"
    case contentType = "Content-Type"
    case authorization = "Authorization"
  }

  struct HTTPHeaders {
    static let acceptJson: HTTPHeaderField = (name: .accept, value: "application/json;charset=utf-8")
    static let contentJson: HTTPHeaderField = (name: .accept, value: "application/json;charset=utf-8")
    static let contentForm: HTTPHeaderField = (name: .accept, value: "application/x-www-form-urlencoded;charset=utf-8")
  }
}

extension APIClientProtocol {
  func getRequestUrl(forEndpoint endpoint: APIEndpoint) -> URL? {
    var urlComponents = URLComponents(string: "\(baseUrl)\(endpoint.path)")

    if let params = endpoint.params {
      urlComponents?.percentEncodedQuery = params
        .filter { $0.encoding == .query }
        .map { $0.value }
        .map { $0.pathQueryString }
        .joined(separator: "&")
    }
    return urlComponents?.url
  }

  func request(endpoint: APIEndpoint) -> Single<Data> {
    return Single<Data>.create { single in
      guard let url = self.getRequestUrl(forEndpoint: endpoint) else {
        single(.error(AppError.failedToConstructUrl("\(self.baseUrl)\(endpoint.path)")))
        return Disposables.create()
      }

      var request = URLRequest(url: url)

      // set HTTP method
      request.httpMethod = endpoint.method.rawValue

      // set request headers, endpoint headers have priority over client headers
      _ = [self.headers, endpoint.headers].joined().map {
        request.setValue($0.value, forHTTPHeaderField: $0.name.rawValue)
      }

      // set body params if there are any
      let bodyParams = endpoint.params?.filter { $0.encoding != .query }.first
      if let params = bodyParams {
        request.httpBody = params.encoding.toData(params: params.value)
      }

      // log request as cURL if in debug mode
      if self.debugMode {
        Log.warning("\n\n\(request.cURL)\n")
      }

      let task = self.session.dataTask(with: request) { data, response, error in
        // if request failed with an error, resolve signal with this error
        if let error = error {
          single(.error(error))
          return
        }

        // if request had body data, resolve signal with success and data
        if let data = data {
          // log body data if in debug mode
          if self.debugMode, let stringResponse = String(data: data, encoding: .utf8) {
            Log.info("\n\n\(stringResponse)\n")
          }
          single(.success(data))
          return
        }

        // if no error and no body data, resolve with custom error
        single(.error(AppError.urlRequestFailed((request, response))))
      }

      task.resume()

      return Disposables.create()
    }
  }
}

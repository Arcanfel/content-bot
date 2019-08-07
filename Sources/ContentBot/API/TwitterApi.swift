import Foundation

extension API {
  struct Twitter {
    typealias Credentials = (key: String, secret: String)

    struct APIClient: APIClientProtocol {
      var baseUrl: String = Constants.twitterUrl
      var session: URLSession = URLSession.shared
      var debugMode: Bool = false
      var headers: [(name: API.HTTPHeader, value: String)] = []

      init(debug: Bool = false) {
        debugMode = debug
      }
    }

    enum Endpoint: APIEndpoint {
      case requestToken(RequestTokenParams)
      case getHomeTweets([String: Any])
      case postStatus(PostStatusParams)

      var path: String {
        switch self {
        case .requestToken:
          return "/oauth2/token"
        case .getHomeTweets:
          return "/1.1/statuses/home_timeline"
        case .postStatus:
          return "/1.1/statuses/update.json"
        }
      }

      var method: API.HTTPMethod {
        switch self {
        case .requestToken, .postStatus:
          return .post
        case .getHomeTweets:
          return .get
        }
      }

      var params: [API.EndpointParams]? {
        switch self {
        case let .requestToken(params):
          return [(value: params.params, encoding: .form)]
        case let .getHomeTweets(params):
          return [(value: params, encoding: .form)]
        case let .postStatus(params):
          return [
            (value: params.query, encoding: .query),
            (value: params.body, encoding: .form)
          ]
        }
      }

      var headers: [(name: API.HTTPHeader, value: String)] {
        switch self {
        case let .requestToken(params):
          return [params.authHeader]
        case .getHomeTweets, .postStatus:
          return []
        }
      }
    }

    private enum Params: String, CodingKey {
      case grantType = "grant_type"
      case includeEntities = "include_entitites"
      case status
      case count
    }

    typealias RequestTokenParams = (params: [String: Any], authHeader: (name: API.HTTPHeader, value: String))
    static func requestTokenParams(credentials: Twitter.Credentials) -> RequestTokenParams {
      guard let credentialsData = "\(credentials.key):\(credentials.secret)".data(using: .utf8) else {
        return (params: [:], authHeader: (name: .authorization, value: ""))
      }

      return (
        params: [Params.grantType.rawValue: "client_credentials"],
        authHeader: (name: .authorization, value: "Basic \(credentialsData.base64EncodedString())")
      )
    }

    typealias PostStatusParams = (query: [String: Any], body: [String: Any])
    static func postStatusParams(status: String) -> PostStatusParams {
      return (
        query: [Params.includeEntities.rawValue: true],
        body: [Params.status.rawValue: status]
      )
    }

    static func requestHomeFeedParams() -> [String: Any] {
      return [
        Params.count.rawValue: 50
      ]
    }

    struct Feed: Codable {}

    struct AuthResponse: Decodable {
      var tokenType: String
      var accessToken: String

      enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
      }
    }
  }
}

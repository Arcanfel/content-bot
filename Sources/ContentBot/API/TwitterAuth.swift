import Foundation
import RxSwift

protocol TwitterAuthDataSource {
  var client: APIClientProtocol { get set }
  func getTimestamp() -> String
  func getNonce() -> String
  func requestUrl() -> String
  func encode(data: String, withKey key: String) -> String?
}

extension TwitterAuthDataSource {
  func encode(data: String, withKey key: String) -> String? {
    let encodingAlgorithm = Crypto.Algorithm.HMACSHA1(key: key)

    if let signature = Crypto.encode(data: data, usingAlgorithm: encodingAlgorithm) {
      return signature
    }
    return nil
  }
}

private struct DataSource: TwitterAuthDataSource {
  var client: APIClientProtocol

  init(client: APIClientProtocol) {
    self.client = client
  }

  func getTimestamp() -> String {
    return String(Date().timeIntervalSince1970)
  }

  func getNonce() -> String {
    return Crypto.randomAlphanumericString()
  }

  func requestUrl() -> String {
    return ""
  }
}

extension API {
  struct TwitterAuth {
    private typealias OAuthKeyValuePair = (key: OAuthKey, value: String)
    private typealias Endpoint = API.Twitter.Endpoint

    enum OAuthKey: String {
      case consumerKey = "oauth_consumer_key"
      case nonce = "oauth_nonce"
      case signatureMethod = "oauth_signature_method"
      case timestamp = "oauth_timestamp"
      case token = "oauth_token"
      case version = "oauth_version"
      case signature = "oauth_signature"
    }

    enum Errors: Error {
      case failedToEncode
    }

    private var credentials: Twitter.Credentials
    private var authToken: String
    private var dataSource: TwitterAuthDataSource
    private static let oauthVersion = "1.0"
    private static let algorithmName = "1.0"
    private static let headerPrefix = "OAuth"

    init(credentials: Twitter.Credentials, authToken: String, dataSource: TwitterAuthDataSource) {
      self.credentials = credentials
      self.authToken = authToken
      self.dataSource = dataSource
    }

    func createAuthHeader(forEndpoint endpoint: API.Twitter.Endpoint) -> Single<String> {
      let timestamp = dataSource.getTimestamp()
      let nonce = dataSource.getNonce()

      let oauthParams: [OAuthKeyValuePair] = [
        (key: .consumerKey, value: credentials.key),
        (key: .nonce, value: nonce),
        (key: .signatureMethod, value: TwitterAuth.algorithmName),
        (key: .timestamp, value: timestamp),
        (key: .token, value: authToken),
        (key: .version, value: TwitterAuth.oauthVersion)
      ]

      return createParameterString(oauthParams: oauthParams, endpoint: endpoint)
        .flatMap { self.createSignatureBaseString(endpoint: endpoint, parameterString: $0) }
        .flatMap { Single.zip(Single.just($0), self.createSigningKey()) }
        .flatMap { base, key in self.calculateSignature(signatureBaseString: base, signingKey: key) }
        .flatMap { self.createHeader(oauthParams: oauthParams, signature: $0) }
    }

    private func createParameterString(oauthParams: [OAuthKeyValuePair], endpoint: Endpoint) -> Single<String> {
      return Single.create { observer in
        var parameters = oauthParams.map {
          (key: $0.key.rawValue, value: $0.value)
        }

        if let endpointParams = endpoint.params {
          parameters.append(
            contentsOf:
            endpointParams
              .map { $0.value }
              .map { dict in
                dict.map {
                  (key: $0.key, value: String(describing: $0.value))
                }
              }
              .flatMap { $0 }
          )
        }

        parameters.sort { $0.key < $1.key }

        let parameterString = parameters
          .map { [$0.key, $0.value] }
          .map { $0.compactMap { $0.urlEncode() }.joined(separator: "=") }
          .joined(separator: "&")

        observer(.success(parameterString))

        return Disposables.create()
      }
    }

    private func createSignatureBaseString(endpoint: Endpoint, parameterString: String) -> Single<String> {
      return Single.create { observer in
        let httpMethod = endpoint.method.rawValue.uppercased()
        let requestUrl = self.dataSource.requestUrl()
        let signatureBaseString = [
          httpMethod,
          requestUrl.urlEncode(),
          parameterString.urlEncode()
        ].compactMap { $0 }.joined(separator: "&")

        observer(.success(signatureBaseString))

        return Disposables.create()
      }
    }

    private func createSigningKey() -> Single<String> {
      return Single.create { observer in
        let signingKey = [self.credentials.secret, self.authToken]
          .map { $0.urlEncode() }
          .compactMap { $0 }
          .joined(separator: "&")

        observer(.success(signingKey))

        return Disposables.create()
      }
    }

    private func calculateSignature(signatureBaseString: String, signingKey: String) -> Single<String> {
      return Single.create { observer in
        if let signature = self.dataSource.encode(data: signatureBaseString, withKey: signingKey) {
          observer(.success(signature))
        } else {
          observer(.error(Errors.failedToEncode))
        }

        return Disposables.create()
      }
    }

    private func createHeader(oauthParams: [OAuthKeyValuePair], signature: String) -> Single<String> {
      return Single.create { observer in
        var parameters = oauthParams + [(key: .signature, value: signature)]
        parameters.sort { $0.key.rawValue < $1.key.rawValue }

        let parameterString = parameters
          .map { [$0.key.rawValue, $0.value] }
          .map { $0.compactMap { $0.urlEncode() }.joined(separator: "=\"").appending("\"") }
          .joined(separator: ", ")

        let authorizationHeader = [TwitterAuth.headerPrefix, parameterString].joined(separator: " ")
        observer(.success(authorizationHeader))

        return Disposables.create()
      }
    }
  }
}

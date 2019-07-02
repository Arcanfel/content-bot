import Foundation
import KituraNet
import RxSwift

/// APIClientProtocol is an implementation of a simple http client.
/// Struct or a class which implements this protocol will need to provide
/// at least baseUrl, and a list of requestOptions (can be empty).
/// An example is a TL.API client.
protocol APIClientProtocol {
    typealias PathClientRequest = (APIEndpoint) -> ClientRequest.Options?
    var baseUrl: String { get set }
    var defaultRequestOptions: [ClientRequest.Options] { get set }

    func getPathRequestOption(endpoint: APIEndpoint) -> ClientRequest.Options

    init()
}

protocol APIEndpoint {
    var path: String { get }
    var method: String { get }
}

enum HTTPMethod: String {
    case get
    case post
}

protocol APIRequest {
    var path: String { get }
    var method: String { get }
}

extension APIClientProtocol {
    private var baseRequestOptions: [ClientRequest.Options] {
        if
            let components = URLComponents(string: baseUrl),
            let host = components.host,
            let scheme = components.scheme {
            return [
                ClientRequest.Options.schema(scheme),
                ClientRequest.Options.hostname(host)
            ]
        }
        return []
    }

    func getPathRequestOption(endpoint: APIEndpoint) -> ClientRequest.Options {
        return ClientRequest.Options.path(endpoint.path)
    }

    func request(endpoint: APIEndpoint) -> Single<Data> {
        return Single<Data>.create { single in
            let pathOption = self.getPathRequestOption(endpoint: endpoint)
            let methodOption = ClientRequest.Options.method(endpoint.method)
            let requestOptions = [
                self.baseRequestOptions,
                self.defaultRequestOptions,
                [pathOption, methodOption]
            ].flatMap { $0 }

            _ = HTTP.request(requestOptions) { response in
                var responseBodyData = Data()
                do {
                    _ = try response?.readAllData(into: &responseBodyData)

                    single(.success(responseBodyData))
                } catch {
                    single(.error(error))
                }
            }.end()
            return Disposables.create()
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Data {
    func map<Result: Decodable>(_ transform: @escaping (Element) throws -> Result.Type) -> Single<Result> {
        return flatMap { value in
            .just(try JSONDecoder().decode(transform(value).self, from: value))
        }
    }
}

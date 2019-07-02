import Foundation
import KituraNet
import RxSwift

struct TL {
    struct APIClient: APIClientProtocol {
        var baseUrl: String = Constants.telegramUrl
        var defaultRequestOptions: [ClientRequest.Options] = []
        var botToken: String = "<bot_token>"

        init() {}

        init(withBotToken token: String) {
            botToken = token
        }

        func getPathRequestOption(endpoint: APIEndpoint) -> ClientRequest.Options {
            return ClientRequest.Options.path("/bot\(botToken)\(endpoint.path)")
        }
    }

    enum Endpoint: String, APIEndpoint {
        case getMe = "/getMe"
        case getUpdates = "/getUpdates"

        var path: String {
            return rawValue
        }

        var method: String {
            switch self {
            case .getMe, .getUpdates:
                return HTTPMethod.get.rawValue
            }
        }
    }

    struct Response<R: Decodable>: Decodable {
        var result: R
        var ok: Bool
    }

    struct User: Decodable {
        var id: Int
        var isBot: Bool
        var firstName: String
        var lastName: String?
        var username: String?
        var languageCode: String?

        enum CodingKeys: String, CodingKey {
            case id
            case isBot = "is_bot"
            case firstName = "first_name"
            case lastName = "last_name"
            case username
            case languageCode = "language_code"
        }
    }

    struct Update: Decodable {
        var updateId: String

        enum CodingKeys: String, CodingKey {
            case updateId = "update_id"
        }
    }
}

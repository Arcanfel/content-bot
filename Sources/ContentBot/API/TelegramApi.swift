import Foundation
import KituraNet
import RxSwift

extension API {
  struct Telegram {
    struct APIClient: APIClientProtocol {
      var baseUrl: String = Constants.telegramUrl
      var botToken: String = "<bot_token>"
      var session: URLSession = URLSession.shared
      var debugMode: Bool = false
      var headers: [API.HTTPHeaderField] = []

      init(withBotToken token: String, debug: Bool) {
        botToken = token
        baseUrl = "\(Constants.telegramUrl)\(botToken)"
        debugMode = debug
      }
    }

    enum Endpoint: APIEndpoint {
      case getMe
      case getUpdates
      case sendMessage(SendMessage)

      var path: String {
        switch self {
        case .getMe: return "/getMe"
        case .getUpdates: return "/getUpdates"
        case .sendMessage: return "/sendMessage"
        }
      }

      var method: API.HTTPMethod {
        switch self {
        case .getMe, .getUpdates:
          return .get
        case .sendMessage:
          return .post
        }
      }

      var params: [API.EndpointParams]? {
        switch self {
        case let .sendMessage(params):
          return [(value: [:], encoding: .json)]
        case .getUpdates, .getMe:
          return nil
        }
      }

      var headers: [API.HTTPHeaderField] {
        return [API.HTTPHeaders.acceptJson, API.HTTPHeaders.contentJson]
      }
    }

    struct Response<R: Decodable>: Decodable {
      var result: R
      var ok: Bool
    }

    struct User: Codable {
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

    struct Update: Codable {
      var updateId: Int
      var message: Message

      enum CodingKeys: String, CodingKey {
        case updateId = "update_id"
        case message
      }
    }

    struct Message: Codable {
      let messageId: Int
      let from: From
      let chat: Chat
      let date: Int
      let text: String
      let entities: [Entity]

      enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case from, chat, date, text, entities
      }
    }

    struct SendMessage: Codable {
      let chatId: Int
      let text: String

      enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case text
      }
    }

    struct Chat: Codable {
      let id: Int
      let firstName, lastName, username, type: String

      enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username, type
      }
    }

    struct Entity: Codable {
      let offset, length: Int
      let type: String
    }

    struct From: Codable {
      let id: Int
      let isBot: Bool
      let firstName, lastName, username, languageCode: String

      enum CodingKeys: String, CodingKey {
        case id
        case isBot = "is_bot"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case languageCode = "language_code"
      }
    }
  }
}

import Foundation
import LoggerAPI
import RxSwift

extension Bot {
  /// All queries to the Telegram Bot API must be served over HTTPS and need
  /// to be presented in this form: https://api.telegram.org/bot<token>/METHOD_NAME. Like this for example:
  /// `https://api.telegram.org/bot123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11/getMe`
  class TelegramBot {
    private let client: API.Telegram.APIClient
    private lazy var pollUpdate: Observable<API.Telegram.Update> = {
      Observable<Int>.interval(.seconds(Int(5)), scheduler: MainScheduler.instance)
        .share()
        .flatMap { _ in self.getUpdates()
          .catchError { error in
            print(error)
            return .just([])
          }
        }
        .map { $0.first }
        .flatMap { $0.map(Observable.just) ?? Observable.empty() }
    }()

    init(withTelegramBotToken botToken: String, debug: Bool = false) {
      client = API.Telegram.APIClient(withBotToken: botToken, debug: debug)
    }

    func getMe() -> Single<API.Telegram.User> {
      return client.request(endpoint: API.Telegram.Endpoint.getMe)
        .map(API.Telegram.Response<API.Telegram.User>.self)
        .map { $0.result }
    }

    func getUpdates() -> Single<[API.Telegram.Update]> {
      return client.request(endpoint: API.Telegram.Endpoint.getUpdates)
        .map(API.Telegram.Response<[API.Telegram.Update]>.self)
        .map { $0.result }
    }

    func sendMessage(chatId: Int, message: String) -> Single<API.Telegram.Message> {
      return client.request(endpoint: API.Telegram.Endpoint.sendMessage(API.Telegram.SendMessage(chatId: chatId, text: message)))
        .map(API.Telegram.Response<API.Telegram.Message>.self)
        .map { $0.result }
    }

    func onCommand() -> Observable<API.Telegram.Update> {
      return pollUpdate
    }
  }
}

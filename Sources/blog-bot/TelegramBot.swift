import Foundation
import KituraNet
import LoggerAPI
import RxSwift

/// All queries to the Telegram Bot API must be served over HTTPS and need
/// to be presented in this form: https://api.telegram.org/bot<token>/METHOD_NAME. Like this for example:
/// `https://api.telegram.org/bot123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11/getMe`
struct TelegramBot {
    private let client: TL.APIClient

    init(withTelegramBotToken botToken: String) {
        client = TL.APIClient(withBotToken: botToken)
    }

    func getMe() -> Single<TL.User> {
        return client.request(endpoint: TL.Endpoint.getMe)
            .map { _ in TL.Response<TL.User>.self }
            .map { $0.result }
    }

    func getUpdates() -> Single<[TL.Update]> {
        return client.request(endpoint: TL.Endpoint.getUpdates)
            .map { _ in [TL.Update].self }
    }
}

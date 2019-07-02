import Foundation
import RxSwift

class ContentBot {
    let server: Server = Server()
    let configuration: AppConfiguration
    let telegramBot: TelegramBot

    private let disposeBag = DisposeBag()

    init(withAppConfiguration appConfiguration: AppConfiguration) {
        configuration = appConfiguration
        telegramBot = TelegramBot(withTelegramBotToken: configuration.telegramBotToken)
    }

    func start() {
        runCodeInInterval()
        RunLoop.main.run()
//    do {
//      try server.run()
//    } catch let error {
//      print(error.localizedDescription)
//    }
    }

    func runCodeInInterval() {
        Observable<Int>.interval(.seconds(Int(2.5)), scheduler: MainScheduler.instance)
            .flatMap { _ in self.telegramBot.getUpdates() }
            .subscribe(onNext: { user in
                print(user)
            }).disposed(by: disposeBag)
    }
}

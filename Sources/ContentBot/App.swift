import Foundation
import LoggerAPI
import RxSwift

public class App {
  let server: Server = Server()
  let configuration: AppConfiguration
  let telegramBot: Bot.TelegramBot
  let twitterBot: Bot.TwitterBot

  private let disposeBag = DisposeBag()

  public init(withConfigurationPath configPath: String) throws {
    guard let appConfiguration = try FileImporter.appConfiguration().importFile(atPath: configPath) else {
      throw AppError.failedToLoadConfig(configPath)
    }

    configuration = appConfiguration
    telegramBot = Bot.TelegramBot(
      withTelegramBotToken: configuration.telegramBotToken,
      debug: configuration.debug
    )

    let credentials = (key: configuration.twitter.apiKey, secret: configuration.twitter.apiSecret)
    twitterBot = Bot.TwitterBot(dataSource: Bot.TwitterBotDataSource(credentials: credentials))
  }

  public func start() {
    if configuration.debug {
      debug()
    } else {
      configureTLBotListener()
      startServer()
    }
    RunLoop.main.run()
  }

  private func startServer() {
    do {
      try server.run()
    } catch {
      print(error.localizedDescription)
    }
  }

  private func configureTLBotListener() {
    telegramBot.onCommand()
      .subscribe { event in
        switch event {
        case let .next(element):
          _ = self.telegramBot.sendMessage(chatId: element.message.chat.id, message: "Yo").subscribe()
        case .completed:
          Log.error("polling stopped")
        case let .error(error):
          print(error)
        }
      }
      .disposed(by: disposeBag)
  }
}

private extension App {
  func debug() {
    devCode()

    while true {
      _ = prompt(message: "command: ")
    }
  }

  func devCode() {
    _ = twitterBot.authenticate()
      .flatMap { self.twitterBot.getHomeTimeline() }
      .subscribe { event in
        print(event)
      }.disposed(by: disposeBag)

//    twitterBot.signRequest(endpoint: API.Twitter.Endpoint.getHomeTweets(API.Twitter.RequestHomeFeedParams()))
//    twitterBot.post(status: "Hello! Ladies + Gentlemen, a signed OAuth request!")
  }

  private func prompt(message: String) -> String? {
    print(message, terminator: "")
    let input = readLine()

    switch input {
    case "": return prompt(message: message)
    case "dev": devCode()
      fallthrough
    default: return input
    }
  }
}

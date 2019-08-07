import Foundation
import LoggerAPI
import RxSwift

// MARK: - Twitter data source

protocol TwitterBotDataSourceProtocol {
  func fetchAuthorizationToken() -> Single<API.Twitter.AuthResponse>
  func fetchHomeTimeline() -> Single<API.Twitter.Feed>
  func urlFor(endpoint: API.Twitter.Endpoint) -> String
  func post(status: String)
}

// MARK: - Twitter bot

protocol TwitterBotProtocol {
  func authenticate() -> Single<Void>
  func getHomeTimeline() -> Single<Bot.TwitterBot.Feed>
  func post(status: String)
}

extension Bot {
  class TwitterBotDataSource: TwitterBotDataSourceProtocol {
    private var client: API.Twitter.APIClient
    private(set) var credentials: API.Twitter.Credentials
    private var authToken: String?

    init(credentials: API.Twitter.Credentials, debug: Bool = false) {
      self.credentials = credentials
      client = API.Twitter.APIClient(debug: debug)
    }

    func fetchAuthorizationToken() -> Single<API.Twitter.AuthResponse> {
      let params = API.Twitter.requestTokenParams(credentials: credentials)
      return client.request(endpoint: API.Twitter.Endpoint.requestToken(params))
        .map(API.Twitter.AuthResponse.self)
        .do(onSuccess: { response in
          self.authToken = response.accessToken
        })
    }

    func fetchHomeTimeline() -> Single<API.Twitter.Feed> {
      let params = API.Twitter.requestHomeFeedParams()
      return client.request(endpoint: API.Twitter.Endpoint.getHomeTweets(params))
        .map(API.Twitter.Feed.self)
    }

    func urlFor(endpoint: API.Twitter.Endpoint) -> String {
      return client.baseUrl + endpoint.path
    }

    func post(status: String) {
      let params = API.Twitter.postStatusParams(status: status)
      let url = client.getRequestUrl(forEndpoint: API.Twitter.Endpoint.postStatus(params))
    }
  }

  class TwitterBot: TwitterBotProtocol {
    typealias Feed = API.Twitter.Feed

    private var dataSource: TwitterBotDataSourceProtocol

    init(dataSource: TwitterBotDataSourceProtocol) {
      self.dataSource = dataSource
    }

    // TODO: UNIT TEST
    func authenticate() -> Single<Void> {
      return dataSource.fetchAuthorizationToken().map { _ in () }
    }

    // TODO: UNIT TEST
    func getHomeTimeline() -> Single<Feed> {
      return dataSource.fetchHomeTimeline()
    }

    func post(status: String) {
      dataSource.post(status: status)
    }
  }
}

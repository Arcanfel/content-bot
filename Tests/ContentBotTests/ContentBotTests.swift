import class Foundation.Bundle
import XCTest
@testable import ContentBot

final class TwitterAuthTests: XCTestCase {
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

  func testExample() throws {
    XCTAssertEqual(true, true)
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}

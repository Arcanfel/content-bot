import Foundation
import Kitura
import LoggerAPI

struct Server {
  let router = Router()
  var port: Int = Constants.defaultPort

  init(port: Int = 8080) {
    self.port = port
    configureRouter()
  }

  private func configureRouter() {
    router.get("/") { _, response, next in
      response.send("Hello world!")
      next()
    }
  }

  public func run() throws {
    print("sup")
    Kitura.addHTTPServer(onPort: 8080, with: router)
    Kitura.run()
  }
}

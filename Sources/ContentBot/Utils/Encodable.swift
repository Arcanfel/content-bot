import Foundation

extension Encodable {
  var jsonData: Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(self)
  }
}

extension Dictionary where Key == String, Value == Any {
  var formQueryData: Data? {
    return map { "\($0.key)=\($0.value)" }
      .joined(separator: "&")
      .data(using: .utf8)
  }

  var jsonData: Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: [])
  }

  var pathQueryString: String {
    return map {
      [$0.key.urlEncode(), String(describing: $0.value).urlEncode()]
        .compactMap { $0 }
        .joined(separator: "=")
    }.joined(separator: "&")
  }
}

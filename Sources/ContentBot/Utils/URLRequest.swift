import Foundation

extension URLRequest {
  var cURL: String {
    guard
      let url = url,
      let httpMethod = httpMethod,
      url.absoluteString.utf8.count > 0
    else {
      return ""
    }

    var curlCommand = "curl --verbose \\\n"

    // URL
    url.absoluteString.withCString {
      curlCommand = curlCommand.appendingFormat(" '%@' \\\n", $0)
    }

    // Method if different from GET
    if httpMethod != "GET" {
      httpMethod.withCString {
        curlCommand = curlCommand.appendingFormat(" -X %@ \\\n", $0)
      }
    }

    // Headers
    let allHeadersFields = allHTTPHeaderFields!
    let allHeadersKeys = Array(allHeadersFields.keys)
    let sortedHeadersKeys = allHeadersKeys.sorted(by: <)
    for key in sortedHeadersKeys {
      key.withCString {
        curlCommand = curlCommand.appendingFormat(" -H '%@: %@' \\\n", $0)
      }
    }

    // HTTP body
    if
      let httpBody = httpBody, httpBody.count > 0,
      let bodyString = String(data: httpBody, encoding: String.Encoding.utf8) {
      let escapedHttpBody = URLRequest.escapeAllSingleQuotes(bodyString)
      escapedHttpBody.withCString {
        curlCommand = curlCommand.appendingFormat(" --data '%@' \n", $0)
      }
    }

    return curlCommand
  }

  /// Escapes all single quotes for shell from a given string.
  static func escapeAllSingleQuotes(_ value: String) -> String {
    return value.replacingOccurrences(of: "'", with: "'\\''")
  }
}

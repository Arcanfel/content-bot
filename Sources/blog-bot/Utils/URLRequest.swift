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
    curlCommand = curlCommand.appendingFormat(" '%@' \\\n", url.absoluteString)

    // Method if different from GET
    if httpMethod != "GET" {
      curlCommand = curlCommand.appendingFormat(" -X %@ \\\n", httpMethod)
    }

    // Headers
    let allHeadersFields = allHTTPHeaderFields!
    let allHeadersKeys = Array(allHeadersFields.keys)
    let sortedHeadersKeys = allHeadersKeys.sorted(by: <)
    for key in sortedHeadersKeys {
      curlCommand = curlCommand.appendingFormat(" -H '%@: %@' \\\n", key, value(forHTTPHeaderField: key)!)
    }

    // HTTP body
    if
      let httpBody = httpBody, httpBody.count > 0,
      let bodyString = String(data: httpBody, encoding: String.Encoding.utf8) {
      let escapedHttpBody = URLRequest.escapeAllSingleQuotes(bodyString)
      curlCommand = curlCommand.appendingFormat(" --data '%@' \n", escapedHttpBody)
    }

    return curlCommand
  }

  /// Escapes all single quotes for shell from a given string.
  static func escapeAllSingleQuotes(_ value: String) -> String {
    return value.replacingOccurrences(of: "'", with: "'\\''")
  }
}

import Cryptor
import Foundation

struct Crypto {
  enum Algorithm {
    case HMACSHA1(key: String)
  }

  static func randomAlphanumericString(_ length: Int = 32) -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomCharacters = (0 ..< length).map { _ in characters.randomElement()! }
    return String(randomCharacters)
  }

  static func encode(data: String, usingAlgorithm algorithm: Algorithm) -> String? {
    switch algorithm {
    case let .HMACSHA1(key):
      return encodeHMACSHA1(data: data, key: key)
    }
  }

  private static func encodeHMACSHA1(data: String, key: String) -> String? {
    let keyData = CryptoUtils.byteArray(from: key)
    let dataToEncode = CryptoUtils.byteArray(from: data)

    if let result = HMAC(using: HMAC.Algorithm.sha1, key: keyData).update(byteArray: dataToEncode)?.final() {
      let data: Data = CryptoUtils.data(from: result)
      return data.base64EncodedString()
    }

    return nil
  }
}

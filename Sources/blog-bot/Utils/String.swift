import Foundation

extension String {
  func removeLastCharacter(_ k: Int = 1) -> String {
    return String(dropLast(k))
  }

  public func urlEncode() -> String? {
    let unreserved = "-._~/?"
    let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
    allowedCharacterSet.removeCharacters(in: "!")
    allowedCharacterSet.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
  }

  init(any: Any) {
    if let bool = any as? Bool {
      self = String(bool)
    } else if let int = any as? Int {
      self = String(int)
    } else if let float = any as? Float {
      self = String(float)
    } else if let string = any as? String {
      self = string
    }

    self = "<unknown_type>"
  }
}

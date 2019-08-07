import Foundation
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait, Element == Data {
  func map<Result: Decodable>(_ targetType: Result.Type) -> Single<Result> {
    return flatMap { value in
      .just(try JSONDecoder().decode(targetType, from: value))
    }
  }
}

import Combine

public extension AnyPublisher {
  static var none: Self {
    return Empty(completeImmediately: true).eraseToAnyPublisher()
  }
}

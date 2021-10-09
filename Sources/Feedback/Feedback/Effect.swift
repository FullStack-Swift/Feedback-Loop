import Combine

public struct Effect<Output, Failure: Error>: Publisher {
  public let upstream: AnyPublisher<Output, Failure>
  
  public init<P: Publisher>(_ publisher: P) where P.Output == Output, P.Failure == Failure {
    self.upstream = publisher.eraseToAnyPublisher()
  }
  
  public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
    self.upstream.subscribe(subscriber)
  }
  
  public init(value: Output) {
    self.init(Just(value).setFailureType(to: Failure.self))
  }
  
  public init(error: Failure) {
    self.init(
      Deferred {
        Future { $0(.failure(error)) }
      }
    )
  }
}

public extension Effect {
  
  static var none: Self {
    Empty(completeImmediately: true).eraseToEffect()
  }
  
  static func future(
    _ attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void
  ) -> Effect {
    Deferred { Future(attemptToFulfill) }.eraseToEffect()
  }
  
  static func result(_ attemptToFulfill: @escaping () -> Result<Output, Failure>) -> Self {
    Deferred { Future { $0(attemptToFulfill()) } }.eraseToEffect()
  }
  
  static func concatenate(_ effects: Effect...) -> Effect {
    .concatenate(effects)
  }
  
  static func concatenate<C: Collection>(
    _ effects: C
  ) -> Effect where C.Element == Effect {
    guard let first = effects.first else { return .none }
    return effects
      .dropFirst()
      .reduce(into: first) { effects, effect in
        effects = effects.append(effect).eraseToEffect()
      }
  }
  
  static func merge(
    _ effects: Effect...
  ) -> Effect {
    .merge(effects)
  }
  
  static func merge<S: Sequence>(_ effects: S) -> Effect where S.Element == Effect {
    Publishers.MergeMany(effects).eraseToEffect()
  }
  
  static func fireAndForget(_ work: @escaping () -> Void) -> Effect {
    Deferred { () -> Publishers.CompactMap<Result<Output?, Failure>.Publisher, Output> in
      work()
      return Just<Output?>(nil)
        .setFailureType(to: Failure.self)
        .compactMap { $0 }
    }
    .eraseToEffect()
  }
  
  func map<T>(_ transform: @escaping (Output) -> T) -> Effect<T, Failure> {
    .init(self.map(transform) as Publishers.Map<Self, T>)
  }
  
}

extension Effect where Failure == Swift.Error {
  public static func catching(_ work: @escaping () throws -> Output) -> Self {
    .future { $0(Result { try work() }) }
  }
}

//MARK: Publisher to Effect
extension Publisher {
  public func eraseToEffect() -> Effect<Output, Failure> {
    Effect(self)
  }
  public func catchToEffect() -> Effect<Result<Output, Failure>, Never> {
    self.map(Result.success)
      .catch { Just(.failure($0)) }
      .eraseToEffect()
  }
  
  public func catchToEffect<T>(
    _ transform: @escaping (Result<Output, Failure>) -> T
  ) -> Effect<T, Never> {
    self
      .map { transform(.success($0)) }
      .catch { Just(transform(.failure($0))) }
      .eraseToEffect()
  }
  public func fireAndForget<NewOutput, NewFailure>(
    outputType: NewOutput.Type = NewOutput.self,
    failureType: NewFailure.Type = NewFailure.self
  ) -> Effect<NewOutput, NewFailure> {
    return flatMap { _ in Empty<NewOutput, Failure>() }
    .catch { _ in Empty() }
    .eraseToEffect()
  }
}

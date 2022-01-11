import Combine

public extension Publisher where Failure == Never {
  func enqueue(to consumer: FeedbackActionConsumer<Output>) -> Publishers.Enqueue<Self> {
    return Publishers.Enqueue(upstream: self, consumer: consumer)
  }
}

public extension Publishers {
  struct Enqueue<Upstream: Publisher>: Publisher where Upstream.Failure == Never {
    public typealias Output = Never
    public typealias Failure = Never
    private let upstream: Upstream
    private let consumer: FeedbackActionConsumer<Upstream.Output>
    
    init(upstream: Upstream, consumer: FeedbackActionConsumer<Upstream.Output>) {
      self.upstream = upstream
      self.consumer = consumer
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
      let token = Token()
      self.upstream.handleEvents(
        receiveOutput: { value in
          self.consumer.process(value, for: token)
        },
        receiveCancel: {
          self.consumer.dequeueAllActions(for: token)
        }
      )
        .flatMap { _ -> Empty<Never, Never> in
          Empty()
        }
        .receive(subscriber: subscriber)
    }
  }
}

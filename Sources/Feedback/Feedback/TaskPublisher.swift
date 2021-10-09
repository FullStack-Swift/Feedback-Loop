import Combine

@available(iOS 15.0, *)
struct TaskPublisher<Output>: Publisher {
  typealias Failure = Never
  
  let work: () async -> Output
  
  init(work: @escaping () async -> Output) {
    self.work = work
  }
  
  func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
    let subscription = TaskSubscription(work: work, subscriber: subscriber)
    subscriber.receive(subscription: subscription)
    subscription.start()
  }
  
  final class TaskSubscription<Output, Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Never {
    private var handle: Task<Output, Never>?
    private let work: () async -> Output
    private let subscriber: Downstream
    
    init(work: @escaping () async -> Output, subscriber: Downstream) {
      self.work = work
      self.subscriber = subscriber
    }
    
    func start() {
      self.handle = Task.init { [subscriber, work] in
        let result = await work()
        _ = subscriber.receive(result)
        subscriber.receive(completion: .finished)
        return result
      }
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
      handle?.cancel()
    }
  }
}

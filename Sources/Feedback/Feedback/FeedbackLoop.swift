import Combine

public extension Publishers {
  struct FeedbackLoop<State, Action, Dependency>: Publisher {
    public typealias Failure = Never
    public typealias Output = State
    let initial: State
    let reduce: Reducer<State, Action>
    let feedbacks: [Feedback<State, Action, Dependency>]
    let dependency: Dependency
    
    public init(
      initial: State,
      reduce: Reducer<State, Action>,
      feedbacks: [Feedback<State, Action, Dependency>],
      dependency: Dependency
    ) {
      self.initial = initial
      self.reduce = reduce
      self.feedbacks = feedbacks
      self.dependency = dependency
    }
    
    public func receive<S>(subscriber: S) where S: Combine.Subscriber, Failure == S.Failure, Output == S.Input {
      let floodgate = Floodgate<State, Action, S, Dependency>(
        state: initial,
        feedbacks: feedbacks,
        subscriber: subscriber,
        reducer: reduce,
        dependency: dependency
      )
      subscriber.receive(subscription: floodgate)
      floodgate.bootstrap()
    }
  }
}

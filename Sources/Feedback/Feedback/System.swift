import Combine
import Foundation

public extension Publishers {
  static func system<State, Action, Dependency>(
    initial: State,
    reduce: Reducer<State, Action>,
    feedbacks: [Feedback<State, Action, Dependency>],
    dependency: Dependency
  ) -> AnyPublisher<State, Never> {
    return Publishers.FeedbackLoop(
      initial: initial,
      reduce: reduce,
      feedbacks: feedbacks,
      dependency: dependency
    )
    .eraseToAnyPublisher()
  }
}

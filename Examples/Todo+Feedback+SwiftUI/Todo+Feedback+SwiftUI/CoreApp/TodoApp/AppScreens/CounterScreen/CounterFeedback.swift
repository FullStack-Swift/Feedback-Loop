import Feedback
import Foundation
import Combine

let CounterFeedback = Feedback {
  Feedback<CounterState, CounterAction, ()>.middleware { state, _ -> AnyPublisher<CounterAction, Never> in
    return .none
  }
}

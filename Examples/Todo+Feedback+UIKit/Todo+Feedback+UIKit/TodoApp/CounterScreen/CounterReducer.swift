import Foundation
import Feedback

let CounterReducer = Reducer<CounterState, CounterAction> { state, action in
  switch action {
  case .increment:
    state.count += 1
  case .decrement:
    state.count -= 1
  }
}

import Foundation
import Feedback

let CounterReducer = Reducer<CounterState, CounterAction> { state, action in
  switch action {
  case .viewDidLoad:
    break
  case .viewWillAppear:
    break
  case .viewWillDisappear:
    break
  case .none:
    break
  case .increment:
    state.count += 1
  case .decrement:
    state.count -= 1
  }
}

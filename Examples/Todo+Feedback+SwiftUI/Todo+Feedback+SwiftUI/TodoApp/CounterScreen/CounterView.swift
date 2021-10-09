import SwiftUI
import Combine
import Feedback

struct CounterView: View {
  
  private let store: Store<CounterState, CounterAction>
  
  @ObservedObject
  private var viewStore: ViewStore<CounterState, CounterAction>
  
  init(store: Store<CounterState, CounterAction>? = nil) {
    let unwrapStore = store ?? Store(initial: CounterState(), feedbacks: [], reducer: CounterReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    HStack {
      Button {
        viewStore.send(.increment)
      } label: {
        Text("+")
      }
      Text("\(viewStore.count)")
      Button {
        viewStore.send(.decrement)
      } label: {
        Text("-")
      }
    }
  }
}

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    CounterView()
  }
}

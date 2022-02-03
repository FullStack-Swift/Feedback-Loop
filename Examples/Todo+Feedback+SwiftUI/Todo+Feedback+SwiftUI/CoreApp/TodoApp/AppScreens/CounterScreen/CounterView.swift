import SwiftUI
import Combine
import Feedback

struct CounterView: View {
  
  private let store: Store<CounterState, CounterAction>
  
  @ObservedObject
  private var viewStore: ViewStore<CounterState, CounterAction>
  
  init(store: Store<CounterState, CounterAction>? = nil) {
    let unwrapStore = store ?? Store(initial: CounterState(), feedback: CounterFeedback, reducer: CounterReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    ZStack {
      HStack {
        Button {
          viewStore.send(.increment)
        } label: {
          Text("+")
        }
        Text(viewStore.count.toString())
        Button {
          viewStore.send(.decrement)
        } label: {
          Text("-")
        }
      }
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    CounterView()
  }
}

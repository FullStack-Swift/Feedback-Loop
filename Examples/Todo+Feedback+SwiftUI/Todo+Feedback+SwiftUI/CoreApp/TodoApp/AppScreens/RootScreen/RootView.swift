import SwiftUI
import Feedback

struct RootView: View {
  
  private let store: Store<RootState, RootAction>
  
  @ObservedObject
  private var viewStore: ViewStore<RootState, RootAction>
  
  init(store: Store<RootState, RootAction>? = nil) {
    let unwrapStore = store ?? Store(initial: RootState(), feedback: RootFeedBack, reducer: RootReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    ZStack {
      switch viewStore.rootScreen {
      case .main:
        MainView(store: store.scope(state: \.mainState, action: RootAction.mainAction))
      case .auth:
        AuthView(store: store.scope(state: \.authState, action: RootAction.authAction))
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

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}

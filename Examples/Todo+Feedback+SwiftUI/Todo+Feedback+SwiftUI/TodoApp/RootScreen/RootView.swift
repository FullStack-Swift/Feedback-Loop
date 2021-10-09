import SwiftUI
import Feedback

struct RootView: View {
  
  private let store: Store<RootState, RootAction>
  
  @ObservedObject
  private var viewStore: ViewStore<RootState, RootAction>
  
  init(store: Store<RootState, RootAction>? = nil) {
    let unwrapStore = store ?? Store(initial: RootState(), feedbacks: [RootFeedback.rootFeeback], reducer: RootReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    switch viewStore.rootScreen {
    case .main:
      MainView(store: store.scope(to: \.mainState, action: RootAction.mainAction))
    case .auth:
      AuthView(store: store.scope(to: \.authState, action: RootAction.authAction))
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}

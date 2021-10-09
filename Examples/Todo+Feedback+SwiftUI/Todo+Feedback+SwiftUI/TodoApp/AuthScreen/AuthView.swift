import SwiftUI
import Feedback

struct AuthView: View {
  
  private let store: Store<AuthState, AuthAction>
  
  @ObservedObject
  private var viewStore: ViewStore<AuthState, AuthAction>
  
  init(store: Store<AuthState, AuthAction>? = nil) {
    let unwrapStore = store ?? Store(initial: AuthState(), feedbacks: [], reducer: AuthReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    ZStack {
      Button("Login") {
        viewStore.send(.changeRootScreen(.main))
      }
    }
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}

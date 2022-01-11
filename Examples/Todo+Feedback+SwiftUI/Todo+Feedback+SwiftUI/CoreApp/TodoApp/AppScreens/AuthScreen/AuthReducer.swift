import Foundation
import Feedback

let AuthReducer = Reducer<AuthState, AuthAction> { state, action in
  switch action {
  case .viewOnAppear:
    break
  case .viewOnDisappear:
    break
  case .none:
    break
  case .login:
    state.status = .login
  case .changeRootScreen(let screen):
    state.status = .none
  }
}

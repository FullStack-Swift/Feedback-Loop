import Foundation
import Feedback

let AuthReducer = Reducer<AuthState, AuthAction> { state, action in
  switch action {
  case .viewDidLoad:
    break
  case .viewWillAppear:
    break
  case .viewWillDisappear:
    break
  case .none:
    break
  case .login:
    state.status = .login
  case .changeRootScreen(let screen):
    state.status = .none
  }
}

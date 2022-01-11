import Foundation
import Combine
import Feedback

let AuthFeedback = Feedback {
  Feedback<AuthState, AuthAction, ()>.middleware { state, _ -> AnyPublisher<AuthAction, Never> in
    switch state.status {
    case .login:
      let publisher = Just(AuthAction.changeRootScreen(.main))
      return publisher.eraseToAnyPublisher()
    default:
      return .none
    }
  }
}

import Foundation
import Feedback
import CasePaths

let RootReducer = Reducer<RootState, RootAction>.combine(
  AuthReducer.pullback(value: \.authState, action: /RootAction.authAction),
  MainReducer.pullback(value: \.mainState, action: /RootAction.mainAction),
  Reducer<RootState, RootAction> { state, action in
    switch action {
    case .mainAction(.changeRootScreen(let screen)):
      state.rootScreen = screen
    case .authAction(.changeRootScreen(let screen)):
      state.rootScreen = screen
    default:
      return
    }
  }
)



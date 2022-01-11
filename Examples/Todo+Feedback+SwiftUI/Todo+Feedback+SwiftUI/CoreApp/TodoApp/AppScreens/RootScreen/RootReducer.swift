import Foundation
import Feedback

let RootReducer = Reducer<RootState, RootAction> {
  AuthReducer.pullback(value: \RootState.authState, action: /RootAction.authAction)
  MainReducer.pullback(value: \RootState.mainState, action: /RootAction.mainAction)
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
}



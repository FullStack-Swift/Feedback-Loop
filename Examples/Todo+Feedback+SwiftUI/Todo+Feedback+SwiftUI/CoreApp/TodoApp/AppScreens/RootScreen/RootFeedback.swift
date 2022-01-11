import Feedback
import Foundation

let RootFeedBack = Feedback<RootState, RootAction, ()> {
  MainFeedback.pullback(value: \RootState.mainState, action: /RootAction.mainAction) { () in
  }
  AuthFeedback.pullback(value: \RootState.authState, action: /RootAction.authAction) { () in
  }
  Feedback<RootState, RootAction, ()>.custom { state, output, dependency in
    state.sink { (state, action) in
      print(state, action as Any)
    }
  }
}

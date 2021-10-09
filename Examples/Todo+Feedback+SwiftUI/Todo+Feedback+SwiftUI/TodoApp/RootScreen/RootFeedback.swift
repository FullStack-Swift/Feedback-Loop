import Feedback
import Foundation
import CasePaths

enum RootFeedback {
  static var rootFeeback: Feedback<RootState, RootAction, ()> {
    MainFeedback.mainFeedback.pullback(value: \.mainState, action: /RootAction.mainAction) { _ in
    }
  }
}


import Foundation

public class FeedbackActionConsumer<Action> {
  func process(_ action: Action, for token: Token) {
    fatalError("This is an abstract class. You must subclass this and provide your own implementation")
  }
  
  func dequeueAllActions(for token: Token) {
    fatalError("This is an abstract class. You must subclass this and provide your own implementation")
  }
}

extension FeedbackActionConsumer {
  func pullback<LocalAction>(_ f: @escaping (LocalAction) -> Action) -> FeedbackActionConsumer<LocalAction> {
    return PullBackConsumer(upstream: self, pull: f)
  }
}

fileprivate final class PullBackConsumer<LocalAction, Action>: FeedbackActionConsumer<LocalAction> {
  private let upstream: FeedbackActionConsumer<Action>
  private let pull: (LocalAction) -> Action
  
  init(upstream: FeedbackActionConsumer<Action>, pull: @escaping (LocalAction) -> Action) {
    self.pull = pull
    self.upstream = upstream
    super.init()
  }
  
  override func process(_ action: LocalAction, for token: Token) {
    self.upstream.process(pull(action), for: token)
  }
  
  override func dequeueAllActions(for token: Token) {
    self.upstream.dequeueAllActions(for: token)
  }
}

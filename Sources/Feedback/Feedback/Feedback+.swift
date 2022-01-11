import Foundation
import Combine

public typealias SimpleFeedback<State, Action> = Feedback<State, Action, Void>

  //MARK: - Custom
public extension Feedback where Dependency == Void {
    /// compacting state
    /// - Returns: Feedback
  static func compacting<NewState, Effect: Publisher>(
    state transform: @escaping (AnyPublisher<State, Never>) -> AnyPublisher<NewState, Never>,
    effects: @escaping (NewState) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    compacting(state: transform) { state, _ in
      effects(state)
    }
  }
  
    /// compacting action
    /// - Returns: Feedback
  static func compacting<NewAction, Effect: Publisher>(
    action transform: @escaping (AnyPublisher<Action, Never>) -> AnyPublisher<NewAction, Never>,
    effects: @escaping (NewAction) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    compacting(action: transform) { action, _ in
      effects(action)
    }
  }
}

  //MARK: - Middleware
public extension Feedback where Dependency == Void {
  static func middleware<Effect: Publisher>(
    _ effects: @escaping (State) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    middleware { state, _ in
      effects(state)
    }
  }
}

import Combine
import Foundation
import CasePaths

final public class Store<State, Action> {
  let box: StoreBoxBase<State, Action>

  public var state: State {
    box._current
  }

  var publisher: AnyPublisher<State, Never> {
    box.publisher
  }

  init(box: StoreBoxBase<State, Action>) {
    self.box = box
  }

  public init<Dependency>(
    initial: State,
    feedbacks: [Feedback<State, Action, Dependency>],
    reducer: Reducer<State, Action>,
    dependency: Dependency
  ) {
    self.box = RootStoreBox(
      initial: initial,
      feedbacks: feedbacks,
      reducer: reducer,
      dependency: dependency
    )
  }

  public func send(action: Action) {
    box.send(action: action)
  }

  public func mutate<V>(keyPath: WritableKeyPath<State, V>, value: V) {
    box.mutate(keyPath: keyPath, value: value)
  }

  public func mutate(with mutation: Mutation<State>) {
    box.mutate(with: mutation)
  }

  public func scope<LocalState, LocalAction>(
    state: WritableKeyPath<State, LocalState>,
    action: @escaping (LocalAction) -> Action
  ) -> Store<LocalState, LocalAction> {
    return Store<LocalState, LocalAction>(box: box.scope(state: state, action: action))
  }
}

public struct Mutation<State> {
  let mutate: (inout State) -> Void

  init<V>(keyPath: WritableKeyPath<State, V>, value: V) {
    self.mutate = { state in
      state[keyPath: keyPath] = value
    }
  }

  init(mutate: @escaping (inout State) -> Void) {
    self.mutate = mutate
  }
}

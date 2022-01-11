import Combine
import CasePaths
import SwiftUI

internal class RootStoreBox<State, Action>: StoreBoxBase<State, Action> {
  private let subject: CurrentValueSubject<State, Never>
  
  private let inputObserver: (Update) -> Void
  private var cancellables = Set<AnyCancellable>()
  
  override var _current: State {
    subject.value
  }
  
  override var publisher: AnyPublisher<State, Never> {
    subject.eraseToAnyPublisher()
  }
  
  public init<Dependency>(
    initial: State,
    feedbacks: [Feedback<State, Action, Dependency>],
    reducer: Reducer<State, Action>,
    dependency: Dependency
  ) {
    let input = Feedback<State, Update, Dependency>.input
    self.subject = CurrentValueSubject(initial)
    self.inputObserver = input.observer
    Publishers.system(
      initial: initial,
      reduce: .init { state, update in
        switch update {
        case .action(let action):
          reducer(&state, action)
        case .mutation(let mutation):
          mutation.mutate(&state)
        }
      },
      feedbacks: feedbacks.map {
        $0.pullback(value: \.self, action: /Update.action, dependency: { _ in dependency })
      }
        .appending(input.feedback),
      dependency: dependency
    )
      .sink(receiveValue: { [subject] state in
        subject.send(state)
      })
      .store(in: &cancellables)
  }
  
  override func send(action: Action) {
    self.inputObserver(.action(action))
  }
  
  override func mutate<V>(keyPath: WritableKeyPath<State, V>, value: V) {
    self.inputObserver(.mutation(Mutation(keyPath: keyPath, value: value)))
  }
  
  override func mutate(with mutation: Mutation<State>) {
    self.inputObserver(.mutation(mutation))
  }
  
  override func scope<S, E>(state: WritableKeyPath<State, S>, action: @escaping (E) -> Action) -> StoreBoxBase<S, E> {
    ScopeStoreBox(parent: self, value: state, action: action)
  }
  
  private enum Update {
    case action(Action)
    case mutation(Mutation<State>)
  }
}

internal class ScopeStoreBox<RootState, RootAction, ScopedState, ScopedAction>: StoreBoxBase<ScopedState, ScopedAction> {
  private let parent: StoreBoxBase<RootState, RootAction>
  private let value: WritableKeyPath<RootState, ScopedState>
  private let actionTransform: (ScopedAction) -> RootAction
  
  override var _current: ScopedState {
    parent._current[keyPath: value]
  }
  
  override var publisher: AnyPublisher<ScopedState, Never> {
    parent.publisher.map(value).eraseToAnyPublisher()
  }
  
  init(
    parent: StoreBoxBase<RootState, RootAction>,
    value: WritableKeyPath<RootState, ScopedState>,
    action: @escaping (ScopedAction) -> RootAction
  ) {
    self.parent = parent
    self.value = value
    self.actionTransform = action
  }
  
  override func send(action: ScopedAction) {
    parent.send(action: actionTransform(action))
  }
  
  override func mutate(with mutation: Mutation<ScopedState>) {
    parent.mutate(with: Mutation<RootState>(mutate: { [value] rootState in
      var scopedState = rootState[keyPath: value]
      mutation.mutate(&scopedState)
      rootState[keyPath: value] = scopedState
    }))
  }
  
  override func mutate<V>(keyPath: WritableKeyPath<ScopedState, V>, value: V) {
    mutate(with: Mutation(keyPath: keyPath, value: value))
  }
  
  override func scope<S, E>(state: WritableKeyPath<ScopedState, S>, action: @escaping (E) -> ScopedAction) -> StoreBoxBase<S, E> {
    ScopeStoreBox<RootState, RootAction, S, E>(
      parent: self.parent,
      value: value.appending(path: state),
      action: { [actionTransform] in actionTransform(action($0)) }
    )
  }
}

public class StoreBoxBase<State, Action> {
  var _current: State { subclassMustImplement() }
  
  var publisher: AnyPublisher<State, Never> { subclassMustImplement() }
  
  func send(action: Action) {
    subclassMustImplement()
  }
  
  func mutate<V>(keyPath: WritableKeyPath<State, V>, value: V) {
    subclassMustImplement()
  }
  
  func mutate(with mutation: Mutation<State>) {
    subclassMustImplement()
  }
  
  func scope<S, E>(
    state: WritableKeyPath<State, S>,
    action: @escaping (E) -> Action
  ) -> StoreBoxBase<S, E> {
    subclassMustImplement()
  }
}

@inline(never)
private func subclassMustImplement(function: StaticString = #function) -> Never {
  fatalError("Subclass must implement `\(function)`.")
}

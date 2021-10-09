import SwiftUI
import Combine
import CombineSchedulers

@dynamicMemberLookup
public final class ViewStore<State, Action>: ObservableObject {
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  public let action = PassthroughSubject<Action, Never>()
  private let _send: (Action) -> Void
  private let mutate: (Mutation<State>) -> Void
  
  fileprivate let _state: CurrentValueSubject<State, Never>
  private var viewCancellable: AnyCancellable?
  private var cancellables: Set<AnyCancellable> = []
  
  public init(
    _ store: Store<State, Action>,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) {
    self._state = CurrentValueSubject(store.box._current)
    self._send = {store.send(action: $0)}
    self.mutate = store.box.mutate
    self.viewCancellable = store.box.publisher
      .receive(on: UIScheduler.shared, options: nil)
      .removeDuplicates(by: isDuplicate)
      .sink { [weak self] in
        guard let self = self else { return }
        self.objectWillChange.send()
        self._state.value = $0
      }
    self.action
      .sink(receiveValue: self.send(_:))
      .store(in: &cancellables)
  }
  
  public var publisher: StorePublisher<State> {
    StorePublisher(viewStore: self)
  }
  
  public var state: State {
    self._state.value
  }
  
  public subscript<U>(dynamicMember keyPath: KeyPath<State, U>) -> U {
    return state[keyPath: keyPath]
  }
  
  public func send(_ action: Action) {
    _send(action)
  }
  
  public func binding<LocalState>(
    get: @escaping (State) -> LocalState,
    send localStateToViewAction: @escaping (LocalState) -> Action
  ) -> Binding<LocalState> {
    ObservedObject(wrappedValue: self)
      .projectedValue[get: .init(rawValue: get), send: .init(rawValue: localStateToViewAction)]
  }
  
  public func binding<U>(for keyPath: KeyPath<State, U>, action: @escaping (U) -> Action) -> Binding<U> {
    return Binding(
      get: {
        self.state[keyPath: keyPath]
      },
      set: {
        self.send(action($0))
      }
    )
  }
  
  public func binding<U>(for keyPath: KeyPath<State, U>, action: Action) -> Binding<U> {
    return Binding(
      get: {
        self.state[keyPath: keyPath]
      },
      set: { _ in
        self.send(action)
      }
    )
  }
  
  public func binding<U>(for keyPath: WritableKeyPath<State, U>) -> Binding<U> {
    return Binding(
      get: {
        self.state[keyPath: keyPath]
      },
      set: {
        self.mutate(Mutation(keyPath: keyPath, value: $0))
      }
    )
  }
  
  private subscript<LocalState>(
    get state: HashableWrapper<(State) -> LocalState>,
    send action: HashableWrapper<(LocalState) -> Action>
  ) -> LocalState {
    get { state.rawValue(self.state) }
    set { self.send(action.rawValue(newValue)) }
  }
}

extension ViewStore where State: Equatable {
  public convenience init(_ store: Store<State, Action>) {
    self.init(store, removeDuplicates: ==)
  }
}

extension ViewStore where State == Void {
  public convenience init(_ store: Store<Void, Action>) {
    self.init(store, removeDuplicates: ==)
  }
}

@dynamicMemberLookup
public struct StorePublisher<State>: Publisher {
  public typealias Output = State
  public typealias Failure = Never
  
  public let upstream: AnyPublisher<State, Never>
  public let viewStore: Any
  
  fileprivate init<Action>(viewStore: ViewStore<State, Action>) {
    self.viewStore = viewStore
    self.upstream = viewStore._state.eraseToAnyPublisher()
  }
  
  public func receive<S>(subscriber: S)
  where S: Subscriber, Failure == S.Failure, Output == S.Input {
    self.upstream.subscribe(
      AnySubscriber(
        receiveSubscription: subscriber.receive(subscription:),
        receiveValue: subscriber.receive(_:),
        receiveCompletion: { [viewStore = self.viewStore] in
          subscriber.receive(completion: $0)
          _ = viewStore
        }
      )
    )
  }
  
  private init<P>(
    upstream: P,
    viewStore: Any
  ) where P: Publisher, Failure == P.Failure, Output == P.Output {
    self.upstream = upstream.eraseToAnyPublisher()
    self.viewStore = viewStore
  }
  
  public subscript<LocalState>(
    dynamicMember keyPath: KeyPath<State, LocalState>
  ) -> StorePublisher<LocalState>
  where LocalState: Equatable {
    .init(upstream: self.upstream.map(keyPath).removeDuplicates(), viewStore: self.viewStore)
  }
}

private struct HashableWrapper<Value>: Hashable {
  let rawValue: Value
  static func == (lhs: Self, rhs: Self) -> Bool { false }
  func hash(into hasher: inout Hasher) {}
}

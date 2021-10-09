import Foundation
import Combine

final class Floodgate<State, Action, S: Subscriber, Dependency>: FeedbackActionConsumer<Action>, Subscription where S.Input == State, S.Failure == Never {
  struct QueueState {
    var actions: [(Action, Token)] = []
    var isOuterLifetimeEnded = false
    var hasActions: Bool {
      actions.isEmpty == false && isOuterLifetimeEnded == false
    }
  }

  let stateDidChange = PassthroughSubject<(State, Action?), Never>()

  private let reducerLock = NSLock()
  private var state: State
  private var hasStarted = false
  private var cancelable: Cancellable?

  private let queue = Atomic(QueueState())
  private let reducer: Reducer<State, Action>
  private let feedbacks: [Feedback<State, Action, Dependency>]
  private let subscriber: S
  private let dependency: Dependency

  init(
    state: State,
    feedbacks: [Feedback<State, Action, Dependency>],
    subscriber: S,
    reducer: Reducer<State, Action>,
    dependency: Dependency
  ) {
    self.state = state
    self.feedbacks = feedbacks
    self.subscriber = subscriber
    self.reducer = reducer
    self.dependency = dependency
  }

  func bootstrap() {
    reducerLock.lock()
    defer { reducerLock.unlock() }

    guard !hasStarted else { return }
    hasStarted = true
    self.cancelable = feedbacks.map {
      $0.action(stateDidChange.eraseToAnyPublisher(), self, dependency)
    }
    _ = self.subscriber.receive(state)
    stateDidChange.send((state, nil))
    drainActions()
  }

  func request(_ demand: Subscribers.Demand) {}

  func cancel() {
    stateDidChange.send(completion: .finished)
    cancelable?.cancel()
    queue.modify {
      $0.isOuterLifetimeEnded = true
    }
  }

  override func process(_ action: Action, for token: Token) {
    enqueue(action, for: token)

    if reducerLock.try() {
      repeat {
        drainActions()
        reducerLock.unlock()
      } while queue.withValue({ $0.hasActions }) && reducerLock.try()
    }
  }

  override func dequeueAllActions(for token: Token) {
    queue.modify { $0.actions.removeAll(where: { _, t in t == token }) }
  }

  private func enqueue(_ action: Action, for token: Token) {
    queue.modify { state -> QueueState in
      state.actions.append((action, token))
      return state
    }
  }

  private func dequeue() -> Action? {
    queue.modify {
      guard !$0.isOuterLifetimeEnded, !$0.actions.isEmpty else {
        return nil
      }
      return $0.actions.removeFirst().0
    }
  }

  private func drainActions() {
    while let next = dequeue() {
      consume(next)
    }
  }

  private func consume(_ action: Action) {
    reducer(&state, action)
    _ = subscriber.receive(state)
    stateDidChange.send((state, action))
  }
}


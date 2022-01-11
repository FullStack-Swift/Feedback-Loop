import CasePaths
import Combine

public struct Feedback<State, Action, Dependency> {
  internal let action: (
    _ state: AnyPublisher<(State, Action?), Never>,
    _ output: FeedbackActionConsumer<Action>,
    _ dependency: Dependency
  ) -> Cancellable
  
  internal init(action: @escaping (
    _ state: AnyPublisher<(State, Action?), Never>,
    _ output: FeedbackActionConsumer<Action>,
    _ dependency: Dependency
  ) -> Cancellable) {
    self.action = action
  }
}

  //MARK: - Custom
public extension Feedback {
  static func custom( action: @escaping (
    _ state: AnyPublisher<(State, Action?), Never>,
    _ output: FeedbackActionConsumer<Action>,
    _ dependency: Dependency
  ) -> Cancellable
  ) -> Feedback {
    return Feedback(action: action)
  }
}

  //MARK: - Compacting
public extension Feedback {
    /// compacting state
    /// - Returns: Feedback
  static func compacting<NewState, Effect: Publisher>(
    state transform: @escaping (AnyPublisher<State, Never>) -> AnyPublisher<NewState, Never>,
    effects: @escaping (NewState, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    custom { (state, output, dependency) -> Cancellable in
      transform(state.map(\.0).eraseToAnyPublisher())
        .flatMapLatest { effects($0, dependency).enqueue(to: output) }
        .start()
    }
  }
  
    /// compacting action
    /// - Returns: Feedback
  static func compacting<NewAction, Effect: Publisher>(
    action transform: @escaping (AnyPublisher<Action, Never>) -> AnyPublisher<NewAction, Never>,
    effects: @escaping (NewAction, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    custom { (state, output, dependency) -> Cancellable in
      transform(state.map(\.1).compactMap { $0 }.eraseToAnyPublisher())
        .flatMapLatest { effects($0, dependency).enqueue(to: output) }
        .start()
    }
  }
}

  //MARK: - SkippingRepeated
public extension Feedback {
  static func skippingRepeated<Control: Equatable, Effect: Publisher>(
    state transform: @escaping (State) -> Control?,
    effects: @escaping (Control, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    compacting(state: {
      $0.map(transform)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }, effects: { control, dependency in
      control
        .map { effects($0, dependency) }?
        .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
    })
  }
  
  @available(iOS 15.0, *)
  static func skippingRepeated<Control: Equatable>(
    state transform: @escaping (State) -> Control?,
    effect: @escaping (Control, Dependency) async -> Action
  ) -> Feedback {
    compacting(state: {
      $0.map(transform)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }, effects: { control, dependency -> AnyPublisher<Action, Never> in
      if let control = control {
        return TaskPublisher {
          await effect(control, dependency)
        }.eraseToAnyPublisher()
      } else {
        return Empty().eraseToAnyPublisher()
      }
    })
  }
  
}

  //MARK: - Predicate
public extension Feedback {
  static func predicate<Effect: Publisher>(
    predicate: @escaping (State) -> Bool,
    effects: @escaping (State, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    return firstValueAfterNil({ state -> State? in
      predicate(state) ? state : nil
    }, effects: effects)
  }
  
  @available(iOS 15.0, *)
  static func predicate(
    predicate: @escaping (State) -> Bool,
    effect: @escaping (State, Dependency) async -> Action
  ) -> Feedback {
    return firstValueAfterNil { state -> State? in
      predicate(state) ? state : nil
    } effect: { state, dependency in
      await effect(state, dependency)
    }
  }
  
}

  //MARK: - Lensing
public extension Feedback {
    /// Lesing State
    /// - Returns: Feedback
  static func lensing<Control, Effect: Publisher>(
    state transform: @escaping (State) -> Control?,
    effects: @escaping (Control, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    compacting(state: {
      $0.map(transform).eraseToAnyPublisher()
    }, effects: { control, dependency in
      control.map { effects($0, dependency) }?
        .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
    })
  }
  
  @available(iOS 15.0, *)
  static func lensing<Control>(
    state transform: @escaping (State) -> Control?,
    effects: @escaping (Control, Dependency) async -> Action
  ) -> Feedback {
    compacting(state: {
      $0.map(transform).eraseToAnyPublisher()
    }, effects: { control, dependency -> AnyPublisher<Action, Never> in
      if let control = control {
        return TaskPublisher {
          await effects(control, dependency)
        }
        .eraseToAnyPublisher()
      } else {
        return Empty().eraseToAnyPublisher()
      }
    })
  }
    /// Lensing Action
    /// - Returns: Feedback
  static func lensing<NewAction, Effect: Publisher>(
    action transform: @escaping (Action) -> NewAction?,
    effects: @escaping (NewAction, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    compacting(action: {
      $0.map(transform).eraseToAnyPublisher()
    }, effects: { payload, dependency in
      payload.map { effects($0, dependency) }?
        .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
    })
  }
  
  @available(iOS 15.0, *)
  static func lensing<NewAction>(
    action transform: @escaping (Action) -> NewAction?,
    effect: @escaping (NewAction, Dependency) async -> Action
  ) -> Feedback {
    compacting(action: {
      $0.map(transform).eraseToAnyPublisher()
    }, effects: { payload, dependency -> AnyPublisher<Action, Never> in
      if let payload = payload {
        return TaskPublisher {
          await effect(payload, dependency)
        }
        .eraseToAnyPublisher()
      } else {
        return Empty().eraseToAnyPublisher()
      }
    })
  }
  
}

  //MARK: - FirstValueAfterNil
public extension Feedback {
  static func firstValueAfterNil<Value, Effect: Publisher>(
    _ transform: @escaping (State) -> Value?,
    effects: @escaping (Value, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    return .compacting(
      state: { state -> AnyPublisher<NilEdgeTransition<Value>, Never> in
        return state.scan((lastWasNil: true, output: NilEdgeTransition<Value>?.none)) { acum, state in
          var temp = acum
          let result = transform(state)
          temp.output = nil
          
          switch (temp.lastWasNil, result) {
          case (true, .none), (false, .some):
            return temp
          case let (true, .some(value)):
            temp.lastWasNil = false
            temp.output = .populated(value)
          case (false, .none):
            temp.lastWasNil = true
            temp.output = .cleared
          }
          return temp
        }
        .compactMap(\.output)
        .eraseToAnyPublisher()
      },
      effects: { transition, dependency -> AnyPublisher<Effect.Output, Effect.Failure> in
        switch transition {
        case let .populated(value):
          return effects(value, dependency).eraseToAnyPublisher()
        case .cleared:
          return Empty().eraseToAnyPublisher()
        }
      }
    )
  }
  
  @available(iOS 15.0, *)
  static func firstValueAfterNil<Value>(
    _ transform: @escaping (State) -> Value?,
    effect: @escaping (Value, Dependency) async -> Action
  ) -> Feedback  {
    .firstValueAfterNil(transform) { value, dependency in
      TaskPublisher {
        await effect(value, dependency)
      }
    }
  }
}

  //MARK: - Middleware
public extension Feedback {
  static func middleware<Effect: Publisher>(
    _ effects: @escaping (State, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    compacting(state: { $0 }, effects: effects)
  }
  
  @available(iOS 15.0, *)
  static func middleware(
    _ effect: @escaping (State, Dependency) async -> Action
  ) -> Feedback {
    compacting(state: { $0 }, effects: { state, dependency in
      TaskPublisher {
        await effect(state, dependency)
      }
    })
  }
  
  static func middleware<Effect: Publisher>(
    _ effects: @escaping (State, Action, Dependency) -> Effect
  ) -> Feedback where Effect.Output == Action, Effect.Failure == Never {
    custom { (state, output, dependency) -> Cancellable in
      state.compactMap { state, action -> (State, Action)? in
        guard let action = action else {
          return nil
        }
        return (state, action)
      }
      .flatMapLatest {
        effects($0, $1, dependency).enqueue(to: output)
      }
      .start()
    }
  }
  
  @available(iOS 15.0, *)
  static func middleware(
    _ effects: @escaping (State, Action, Dependency) async -> Action
  ) -> Feedback {
    custom { (state, output, dependency) -> Cancellable in
      state.compactMap { state, action -> (State, Action)? in
        guard let action = action else {
          return nil
        }
        return (state, action)
      }
      .flatMapLatest { state, action in
        TaskPublisher {
          await effects(state, action, dependency)
        }
        .enqueue(to: output)
      }
      .start()
    }
  }
  
  @available(iOS 15.0, *)
  static func middleware(
    _ effect: @escaping (Action, Dependency) async -> Action
  ) -> Feedback {
    custom { (state, output, dependency) -> Cancellable in
      state.compactMap { _, action -> Action? in
        guard let action = action else {
          return nil
        }
        return action
      }
      .flatMapLatest { action in
        TaskPublisher {
          await effect(action, dependency)
        }
        .enqueue(to: output)
      }
      .start()
    }
  }
}

  //MARK: - Pullback
public extension Feedback {
  func pullback<GlobalState, GlobalAction, GlobalDependency>(
    value: KeyPath<GlobalState, State>,
    action: CasePath<GlobalAction, Action>,
    dependency toLocal: @escaping (GlobalDependency) -> Dependency
  ) -> Feedback<GlobalState, GlobalAction, GlobalDependency> {
    return .custom { (state, consumer, dependency) -> Cancellable in
      let state = state.map {
        ($0[keyPath: value], $1.flatMap(action.extract(from:)))
      }.eraseToAnyPublisher()
      return self.action(
        state,
        consumer.pullback(action.embed),
        toLocal(dependency)
      )
    }
  }
}

  //MARK: - Combine
public extension Feedback {
  static func combine (
    _ feedbacks: Feedback...
  ) -> Feedback {
    custom { (state, consumer, dependency) -> Cancellable in
      feedbacks.map { (feedback) -> Cancellable in
        feedback.action(state, consumer, dependency)
      }
    }
  }
  
  static func combine (
    _ feedbacks: [Feedback] = []
  ) -> Feedback {
    custom { (state, consumer, dependency) -> Cancellable in
      feedbacks.map { (feedback) -> Cancellable in
        feedback.action(state, consumer, dependency)
      }
    }
  }
}

public extension Feedback {
  init(@ArrayBuilder<Feedback<State, Action, Dependency>> builder: () -> [Feedback<State, Action, Dependency>]) {
    self = Self.combine(builder())
  }
}

  //MARK: - Input
public extension Feedback {
  static var input: (feedback: Feedback, observer: (Action) -> Void) {
    let subject = PassthroughSubject<Action, Never>()
    let feedback = custom { (_, consumer, _) -> Cancellable in
      subject.enqueue(to: consumer).start()
    }
    return (feedback, subject.send)
  }
}

private enum NilEdgeTransition<Value> {
  case populated(Value)
  case cleared
}

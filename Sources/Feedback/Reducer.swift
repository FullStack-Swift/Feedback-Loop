import CasePaths

public struct Reducer<State, Action> {
  public let reduce: (inout State, Action) -> Void
    /// Initializes a reducer from a simple reducer function signature.
    ///
    /// The reducer takes two arguments: state and action. The state is `inout` so that
    /// you can make any changes to it directly inline.
    /// For example:
    /// ```swift
    ///  struct RootState: Equatable {
    ///      var rootScreen: RootScreen = .main
    ///  }
    /// enum RootAction: Equatable {
    ///   case authAction(AuthAction)
    ///   case mainAction(MainAction)
    /// }
    ///    Reducer<RootState, RootAction> { state, action in
    ///      switch action {
    ///      case .mainAction(.changeRootScreen(let screen)):
    ///        state.rootScreen = screen
    ///      case .authAction(.changeRootScreen(let screen)):
    ///        state.rootScreen = screen
    ///      default:
    ///        return
    ///      }
    ///    }
    ///  }
    /// ```
  public init(reduce: @escaping (inout State, Action) -> Void) {
    self.reduce = reduce
  }
}

// MARK: -  Create  the Reducer
extension Reducer {
    /// A reducer that performs no state mutations
  public static var empty: Reducer {
    Self { _, _ in }
  }
    /// - Parameter reducers: An array of reducers.
    /// - Returns: A single reducer.
    ///  ```swift
    ///  let RootReducer = Reducer<RootState, RootAction> {
    ///    AuthReducer.pullback(value: \RootState.authState, action: /RootAction.authAction)
    ///    MainReducer.pullback(value: \RootState.mainState, action: /RootAction.mainAction)
    ///    Reducer<RootState, RootAction> { state, action in
    ///      switch action {
    ///      case .mainAction(.changeRootScreen(let screen)):
    ///        state.rootScreen = screen
    ///      case .authAction(.changeRootScreen(let screen)):
    ///        state.rootScreen = screen
    ///      default:
    ///        return
    ///      }
    ///    }
    ///  }
    ///  ```
  public init(@ArrayBuilder<Reducer<State, Action>> builder: () -> [Reducer<State, Action>]) {
    self = Self.combine(builder())
  }
  
    /// - Parameter reducers: An array of reducers.
    /// - Returns: A single reducer.
  public static func combine(_ reducers: Reducer...) -> Reducer {
    return .init { state, action in
      for reducer in reducers {
        reducer(&state, action)
      }
    }
  }
    /// - Parameter reducers: An array of reducers.
    /// - Returns: A single reducer.
  public static func combine(_ reducers: [Reducer]) -> Reducer {
    return .init { state, action in
      for reducer in reducers {
        reducer(&state, action)
      }
    }
  }
}

  /// Pullback the reducer
  /// - Returns: Reducer
extension Reducer {
  public func pullback<GlobalState, GlobalAction>(
    value: WritableKeyPath<GlobalState, State>,
    action: CasePath<GlobalAction, Action>
  ) -> Reducer<GlobalState, GlobalAction> {
    return .init { globalState, globalAction in
      guard let localAction = action.extract(from: globalAction) else {
        return
      }
      self(&globalState[keyPath: value], localAction)
    }
  }
}

  /// Runs the reducer.
  ///
  /// - Parameters:
  ///   - state: Mutable state.
  ///   - action: An action.
extension Reducer {
  public func run(
    _ state: inout State,
    _ action: Action
  ) {
    self.reduce(&state, action)
  }
  
  public func callAsFunction(
    _ state: inout State,
    _ action: Action
  ) {
    self.reduce(&state, action)
  }
}

import CasePaths

public struct Reducer<State, Action> {
  public let reduce: (inout State, Action) -> Void
  
  public init(reduce: @escaping (inout State, Action) -> Void) {
    self.reduce = reduce
  }
  
  public func callAsFunction(_ state: inout State, _ action: Action) {
    self.reduce(&state, action)
  }
  
  public static func combine(_ reducers: Reducer...) -> Reducer {
    return .init { state, action in
      for reducer in reducers {
        reducer(&state, action)
      }
    }
  }
  
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

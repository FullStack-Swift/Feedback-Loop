import Combine
import SwiftUI

public struct WithViewStore<State, Action, Content> {
  @ObservedObject
  private var viewStore: ViewStore<State, Action>
  private let content: (ViewStore<State, Action>) -> Content
  
  public init(
    store: Store<State, Action>,
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool,
    content: @escaping (ViewStore<State, Action>) -> Content
  ) {
    self.content = content
    self.viewStore = ViewStore(store, removeDuplicates: isDuplicate)
  }
  
  public var _body: Content {
    return content(viewStore)
  }
}

extension WithViewStore: View where Content: View {
  public var body: Content {
    _body
  }
}

extension WithViewStore where State: Equatable, Content: View {
  public init(
    store: Store<State, Action>,
    @ViewBuilder content: @escaping (ViewStore<State, Action>) -> Content
  ) {
    self.init(store: store, removeDuplicates: ==, content: content)
  }
}

extension WithViewStore where State == Void, Content: View {
  public init(
    store: Store<State, Action>,
    @ViewBuilder content: @escaping (ViewStore<State, Action>) -> Content
  ) {
    self.init(store: store, removeDuplicates: ==, content: content)
  }
}

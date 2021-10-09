import SwiftUI
import Feedback

struct MainView: View {
  
  private let store: Store<MainState, MainAction>
  
  @ObservedObject
  private var viewStore: ViewStore<MainState, MainAction>
  
  init(store: Store<MainState, MainAction>? = nil) {
    let unwrapStore = store ?? Store(initial: MainState(), feedbacks: [singAllMainFeedBack], reducer: MainReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  
  var body: some View {
    ZStack {
        List {
            HStack {
                Spacer()
                Text(viewStore.isLoading ? "Loading" : "Reload")
                    .bold()
                Spacer()
            }
            .onTapGesture {
                viewStore.send(.getTodo)
            }
            HStack {
              TextField("title", text: viewStore.binding(for: \.title))
                Button(action: {
                    viewStore.send(.createTodo)
                }, label: {
                    Text("Create")
                        .bold()
                        .foregroundColor(viewStore.title.isEmpty ? Color.gray : Color.green)
                })
                    .disabled(viewStore.title.isEmpty)
            }
            
            ForEach(viewStore.todos) { todo in
                HStack {
                    HStack {
                      Image(systemName: todo.isCompleted ? "checkmark.square" : "square")
                        Text(todo.title)
                            .underline(todo.isCompleted, color: Color.black)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.updateTodo(todo))
                    }
                    Button(action: {
                        viewStore.send(.deleteTodo(todo))
                    }, label: {
                        Text("Delete")
                            .foregroundColor(Color.gray)
                    })
                }
            }
#if os(iOS)
            .listStyle(PlainListStyle())
#else
            .listStyle(PlainListStyle())
#endif
            
            .padding(.all, 0)
        }
        .padding(.all, 0)
#if os(macOS)
        .toolbar {
            ToolbarItem(placement: .status) {
                VStack {
                    Spacer()
                    Button(action: {
                      viewStore.send(.changeRootScreen(.auth))
                    }, label: {
                        Text("Logout")
                            .foregroundColor(Color.blue)
                    })
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
#if os(iOS)
        .navigationTitle("Todos")
        .navigationViewStyle(.stack)
        .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
        .embedNavigationView()
#endif
    }
    .onAppear {
      viewStore.send(.getTodo)
    }
  }
}

extension MainView {
    
    private var leadingBarItems: some View {
      CounterView()
    }
    
    private var trailingBarItems: some View {
        Button(action: {
          viewStore.send(.changeRootScreen(.auth))
        }, label: {
            Text("Logout")
                .foregroundColor(Color.blue)
        })
    }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}

extension View {
    func embedNavigationView() -> some View {
        NavigationView {
            self
        }
    }
}

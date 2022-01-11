import Feedback
import SwiftUI

struct MainView: View {
  
  private let store: Store<MainState, MainAction>
  
  @ObservedObject
  private var viewStore: ViewStore<MainState, MainAction>
  
  init(store: Store<MainState, MainAction>? = nil) {
    let unwrapStore = store ?? Store(initial: MainState(), feedback: MainFeedback, reducer: MainReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }
  var body: some View {
    ZStack {
      NavigationView {
        content
          .navigationTitle("Todos")
          .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
      }
      .navigationViewStyle(.stack)
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}


extension MainView {
    /// create content view in screen
  private var content: some View {
    List {
      Section {
        ZStack {
          HStack {
            Spacer()
            if viewStore.isLoading {
              ProgressView()
            } else {
              Text("Reload")
                .bold()
                .onTapGesture {
                  viewStore.send(.getTodo)
                }
            }
            Spacer()
          }
          .frame(height: 60)
        }
      }
      HStack {
        TextField("title", text: viewStore.binding(for: \.title))
        Button(action: {
          viewStore.send(.createOrUpdateTodo)
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
              .frame(width: 40, height: 40, alignment: .center)
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
      .padding(.all, 0)
    }
    .padding(.all, 0)
  }
  
  private var leadingBarItems: some View {
    CounterView(store: store.scope(state: \.counterState, action: MainAction.counterAction))
  }
  
  private var trailingBarItems: some View {
    Button(action: {
      viewStore.send(.logout)
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

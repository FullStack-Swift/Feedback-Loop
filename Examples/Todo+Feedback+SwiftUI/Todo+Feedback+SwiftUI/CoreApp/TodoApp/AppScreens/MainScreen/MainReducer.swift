import Foundation
import Feedback
import Json
import ConvertSwift

let MainReducer = Reducer<MainState, MainAction>.combine(
  CounterReducer.pullback(value: \.counterState, action: /MainAction.counterAction),
  Reducer<MainState, MainAction> { state, action in
    switch action {
    case .viewOnAppear:
      state.status = .getTodo
      state.isLoading = true
      state.todos.removeAll()
    case .changeText(let value):
      state.title = value
    case .logout:
      state.status = .logout
    case .changeRootScreen(let screen):
      state.status = .none
      /// getTodo
    case .getTodo:
      state.status = .getTodo
      state.isLoading = true
      state.todos.removeAll()
    case .responseTodo(let data):
      state.isLoading = false
      state.status = .none
      if let todos = data.toModel([TodoModel].self) {
        for todo in todos {
          state.todos.append(todo)
        }
      }
      /// createOrUpdateTodo
    case .createOrUpdateTodo:
      let title = state.title
      if title.isEmpty {
        let todo = TodoModel(id: UUID(), title: title, isCompleted: true)
        state.status = .createOrUpdateTodo(todo)
      }
    case .responseCreateOrUpdateTodo(let data):
      state.status = .none
      state.title = ""
      if let todo = data.toModel(TodoModel.self) {
        state.todos.append(todo)
      }
      /// updateTodo
    case .updateTodo(let todo):
      var todo = todo
      todo.isCompleted.toggle()
      state.status = .updateTodo(todo)
    case .responseUpdateTodo(let data):
      state.status = .none
      if let todo = data.toModel(TodoModel.self) {
        if let index = state.todos.firstIndex(where: { item in
          item.id == todo.id
        }) {
          state.todos[index] = todo
        }
      }
      /// deleteTodo
    case .deleteTodo(let todo):
      state.status = .deleteTodo(todo)
    case .reponseDeleteTodo(let data):
      state.status = .none
      if let todo = data.toModel(TodoModel.self) {
        state.todos.removeAll {
          $0.id == todo.id
        }
      }
    default:
      break
    }
  }
)

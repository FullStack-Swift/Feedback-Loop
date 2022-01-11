import Foundation
import Feedback
import ConvertSwift

let MainReducer = Reducer<MainState, MainAction> {state, action in
  switch action {
      /// view action
  case .viewDidLoad:
    state.status = .getTodo
    state.isLoading = true
    state.todos.removeAll()
  case .changeText(let value):
    state.title = value
  case .logout:
    state.status = .logout
  case .changeRootScreen(let screen):
    state.status = .none
      /// get todo
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
      /// create Todo
  case .createTodo:
    let title = state.title
    if !title.isEmpty {
      let id = UUID()
      let todo = TodoModel(id: id, title: title, isCompleted: false)
      state.status = .createTodo(todo)
      state.title = ""
    }
  case .responseCreateTodo(let data):
    state.status = .none
    if let todo = data.toModel(TodoModel.self) {
      state.todos.append(todo)
    }
      /// update Todo
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
      /// delete Todo
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

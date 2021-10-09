import Foundation
import Feedback
import Json
import ConvertSwift

let MainReducer = Reducer<MainState, MainAction> {state, action in
  switch action {
    
    /// get todo
  case .getTodo:
    state.status = .getTodo
    state.isLoading = true
    state.todos.removeAll()
  case .responseTodo(let data):
    state.isLoading = false
    state.status = .none
    if let todos = data.toModel([Todo].self) {
      for todo in todos {
        state.todos.append(todo)
      }
    }
    
    /// create Todo
  case .createTodo:
    state.status = .createTodo(state.title)
    state.title = ""
  case .responseCreateTodo(let data):
    state.status = .none
    if let todo = data.toModel(Todo.self) {
      state.todos.append(todo)
    }
    /// update Todo
  case .updateTodo(let todo):
    var todo = todo
    todo.isCompleted.toggle()
    state.status = .updateTodo(todo)
  case .responseUpdateTodo(let data):
    state.status = .none
    if let todo = data.toModel(Todo.self) {
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
    if let todo = data.toModel(Todo.self) {
      state.todos.removeAll {
        $0.id == todo.id
      }
    }
    
  case .changeTextFieldTitle(let title):
    state.title = title
  case .changeRootScreen(let screen):
    break
  default:
    break
  }
}

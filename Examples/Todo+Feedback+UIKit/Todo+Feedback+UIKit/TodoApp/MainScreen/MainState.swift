import Foundation

struct MainState: Equatable {
  var title: String = ""
  var todos: [Todo] = []
  var isLoading: Bool = false
  var status: StatusTodo = .none
}

enum StatusTodo: Equatable {
  case getTodo
  case updateTodo(Todo)
  case deleteTodo(Todo)
  case createTodo(String)
  case none
}

import Foundation

struct MainState: Equatable {
  var counterState = CounterState()
  var title: String = ""
  var todos: [TodoModel] = []
  var isLoading: Bool = false
  var status: StatusTodo = .none
}

enum StatusTodo: Equatable {
  case getTodo
  case updateTodo(TodoModel)
  case deleteTodo(TodoModel)
  case createOrUpdateTodo(TodoModel)
  case logout
  case none
}

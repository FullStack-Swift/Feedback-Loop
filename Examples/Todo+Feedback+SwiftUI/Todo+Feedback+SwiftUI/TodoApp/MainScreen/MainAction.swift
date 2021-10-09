import Foundation

enum MainAction: Equatable {
  case getTodo
  case responseTodo(Data)
  case createTodo
  case responseCreateTodo(Data)
  case updateTodo(Todo)
  case responseUpdateTodo(Data)
  case deleteTodo(Todo)
  case reponseDeleteTodo(Data)
  case changeRootScreen(RootScreen)
  case logout
  case none
}

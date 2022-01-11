import Foundation

enum MainAction: Equatable {
    // MARK: -  View Action
    /// lifecycle action
  case viewDidLoad
  case viewWillAppear
  case viewWillDisappear
  case viewDeinit
    ///  navigation view
  case logout
  case changeRootScreen(RootScreen)
  
    /// binding
  case changeText(String)
  case getTodo
  case responseTodo(Data)
  case createTodo
  case responseCreateTodo(Data)
  case updateTodo(TodoModel)
  case responseUpdateTodo(Data)
  case deleteTodo(TodoModel)
  case reponseDeleteTodo(Data)
}

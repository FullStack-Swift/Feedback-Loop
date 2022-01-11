import Foundation

enum MainAction: Equatable {
  case counterAction(CounterAction)
    // MARK: -  View Action
    /// lifecycle action
  case viewOnAppear
  case viewOnDisappear
  case none
    ///  navigation view
  case logout
  case changeRootScreen(RootScreen)
  
    /// binding
  case changeText(String)
  case getTodo
  case responseTodo(Data)
  case createOrUpdateTodo
  case responseCreateOrUpdateTodo(Data)
  case updateTodo(TodoModel)
  case responseUpdateTodo(Data)
  case deleteTodo(TodoModel)
  case reponseDeleteTodo(Data)
}

import Feedback
import Combine
import CombineRequest
import CombineSchedulers
import ConvertSwift

let urlString = "https://todolistappproj.herokuapp.com/todos"

let MainFeedback = Feedback<MainState, MainAction, ()> {
  Feedback<MainState, MainAction, ()>.middleware { state, _ -> AnyPublisher<MainAction, Never> in
    switch state.status {
    case .logout:
      let publisher = Just(MainAction.changeRootScreen(.auth))
      return publisher.eraseToAnyPublisher()
    case .getTodo:
      let request = MRequest {
        RMethod(.get)
        RUrl(urlString: urlString)
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseTodo)
        .eraseToAnyPublisher()
    case .createTodo(let todo):
      let request = MRequest {
        RUrl(urlString: urlString)
        REncoding(.json)
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseCreateTodo)
        .eraseToAnyPublisher()
    case .updateTodo(let todo):
      let request = MRequest {
        REncoding(.json)
        RUrl(urlString: urlString)
          .withPath(todo.id.toString())
        RMethod(.post)
        Rbody(todo.toData())
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.responseUpdateTodo)
        .eraseToAnyPublisher()
    case .deleteTodo(let todo):
      let request = MRequest {
        RUrl(urlString: urlString)
          .withPath(todo.id.toString())
        RMethod(.delete)
      }
      return request
        .compactMap {$0.data}
        .map(MainAction.reponseDeleteTodo)
        .eraseToAnyPublisher()
    default:
      return .none
    }
  }
}

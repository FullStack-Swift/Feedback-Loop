import Feedback
import Combine
import AnyRequest
import CombineSchedulers
import CasePaths
import ConvertSwift

let allMainFeedBack: [Feedback<MainState, MainAction, ()>] = [MainFeedback.getTodo, MainFeedback.createTodo, MainFeedback.updateTodo, MainFeedback.deleteTodo]
let singAllMainFeedBack = Feedback.combine(allMainFeedBack)
enum MainFeedback {
  static var mainFeedback: Feedback<MainState, MainAction, ()> {
    .middleware { state, _ -> AnyPublisher<MainAction, Never> in
      let urlString = "http://127.0.0.1:8080/todos"
      switch state.status {
      case .getTodo:
        let request = Request {
          RMethod(.get)
          RUrl(urlString: urlString)
        }
        return request
          .delay(for: .seconds(1), scheduler: UIScheduler.shared) // fake loading
          .compactMap {$0.data}
          .map(MainAction.responseTodo)
          .eraseToAnyPublisher()
      case .createTodo:
        if state.title.isEmpty {
          return .none
        }
        let todo = Todo(id: nil, title: state.title, isCompleted: false)
        let request = Request {
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
        let request = Request {
          REncoding(.json)
          RUrl(urlString: urlString).withPath(todo.id)
          RMethod(.post)
          Rbody(todo.toData())
        }
        return request
          .compactMap {$0.data}
          .map(MainAction.responseUpdateTodo)
          .eraseToAnyPublisher()
      case .deleteTodo(let todo):
        let request = Request {
          RUrl(urlString: urlString).withPath(todo.id)
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
  
  static var getTodo: Feedback<MainState, MainAction, ()> {
    .middleware { state, _ -> AnyPublisher<MainAction, Never> in
      let urlString = "http://127.0.0.1:8080/todos"
      switch state.status {
      case .getTodo:
        let request = Request {
          RMethod(.get)
          RUrl(urlString: urlString)
        }
        return request
          .delay(for: .seconds(1), scheduler: UIScheduler.shared) // fake loading
          .compactMap {$0.data}
          .map(MainAction.responseTodo)
          .eraseToAnyPublisher()
      default:
        return .none
      }
    }
  }
  
  static var createTodo: Feedback<MainState, MainAction, ()> {
    .middleware { state, _ -> AnyPublisher<MainAction, Never> in
      let urlString = "http://127.0.0.1:8080/todos"
      switch state.status {
      case .createTodo:
        if state.title.isEmpty {
          return .none
        }
        let todo = Todo(id: nil, title: state.title, isCompleted: false)
        let request = Request {
          RUrl(urlString: urlString)
          REncoding(.json)
          RMethod(.post)
          Rbody(todo.toData())
        }
        return request
          .compactMap {$0.data}
          .map(MainAction.responseCreateTodo)
          .eraseToAnyPublisher()
      default:
        return .none
      }
    }
  }
  
  static var updateTodo: Feedback<MainState, MainAction, ()> {
    .middleware { state, _ -> AnyPublisher<MainAction, Never> in
      let urlString = "http://127.0.0.1:8080/todos"
      switch state.status {
      case .updateTodo(let todo):
        let request = Request {
          REncoding(.json)
          RUrl(urlString: urlString).withPath(todo.id)
          RMethod(.post)
          Rbody(todo.toData())
        }
        return request
          .compactMap {$0.data}
          .map(MainAction.responseUpdateTodo)
          .eraseToAnyPublisher()
      default:
        return .none
      }
    }
  }
  
  static var deleteTodo: Feedback<MainState, MainAction, ()> {
    .middleware { state, _ -> AnyPublisher<MainAction, Never> in
      let urlString = "http://127.0.0.1:8080/todos"
      switch state.status {
      case .deleteTodo(let todo):
        let request = Request {
          RUrl(urlString: urlString).withPath(todo.id)
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
}

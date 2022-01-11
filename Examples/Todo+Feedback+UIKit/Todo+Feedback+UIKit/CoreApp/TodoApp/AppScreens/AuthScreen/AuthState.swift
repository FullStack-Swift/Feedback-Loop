import Foundation

struct AuthState: Equatable {
  var status: StatusAuth = .none
}

enum StatusAuth: Equatable {
  case login
  case none
}

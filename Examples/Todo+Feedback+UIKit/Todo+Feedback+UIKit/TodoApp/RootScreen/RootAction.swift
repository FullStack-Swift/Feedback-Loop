import Foundation

enum RootAction: Equatable {
  case authAction(AuthAction)
  case mainAction(MainAction)
}

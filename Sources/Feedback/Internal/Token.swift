import Foundation

struct Token: Equatable {
  let value: UUID
  
  init() {
    value = UUID()
  }
}

import Foundation
import Combine

extension Array {
  func appending(_ element: Element) -> [Element] {
    var copy = self
    copy.append(element)
    return copy
  }
}

extension Array: Cancellable where Element == Cancellable {
  public func cancel() {
    for element in self {
      element.cancel()
    }
  }
}

@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildBlock(_ components: Element...) -> [Element] {
        components
    }
}

public extension Array {
  init(@ArrayBuilder<Element> builder: () -> [Element]) {
      self = builder()
  }
}

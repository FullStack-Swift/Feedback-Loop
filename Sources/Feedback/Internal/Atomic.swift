import Foundation

final class Atomic<Value> {
  private let lock: NSLock
  private var _value: Value

  var value: Value {
    get {
      return withValue { $0 }
    }

    set(newValue) {
      swap(newValue)
    }
  }

  init(_ value: Value) {
    _value = value
    lock = NSLock()
  }

  @discardableResult
  func modify<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result {
    lock.lock()
    defer { lock.unlock() }

    return try action(&_value)
  }

  @discardableResult
  func withValue<Result>(_ action: (Value) throws -> Result) rethrows -> Result {
    lock.lock()
    defer { lock.unlock() }

    return try action(_value)
  }

  @discardableResult
  func swap(_ newValue: Value) -> Value {
    return modify { (value: inout Value) in
      let oldValue = value
      value = newValue
      return oldValue
    }
  }
}

import Foundation

@propertyWrapper
struct Atomic<Value> {
    private var value: Value
    private let lock = NSLock()
    private typealias Mutator = (inout Value) -> Value

    var wrappedValue: Value {
        mutating get { withLock { $0 } }
        set { withLock { $0 = newValue; return $0 } }
    }

    init(_ value: Value) {
        self.value = value
    }

    @discardableResult
    private mutating func withLock(_ action: Mutator) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return action(&value)
    }
}

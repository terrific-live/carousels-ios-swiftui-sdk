import Foundation

/// HTTP Client headers type
public struct Headers {
    public typealias HeadersType = [String: String]
    public var headers: HeadersType

    public init(_ headers: HeadersType) {
        self.headers = headers
    }
}

extension Headers: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        let headers: [String: String] = elements
            .reduce([:]) { partial, next in
                var partial = partial
                partial[next.0] = next.1
                return partial
            }

        self.headers = headers
    }
}

public extension Headers {
    func forEach(_ body: (HeadersType.Element) -> Void) {
        headers.forEach(body)
    }
}

extension Headers: CustomStringConvertible {
    public var description: String {
        var string = ""

        headers.forEach { header, value in
            string += "\(header): \(value)\n"
        }

        return string
    }
}

extension Headers: Equatable {}

import Foundation

private func makeQueryItems(for key: String, value: Any?) -> [URLQueryItem] {
    switch value {
    case let array as [Any]:
        return array.map { URLQueryItem(name: key, value: String(describing: $0)) }
    case .none:
        return []
    case .some(let value):
        return [URLQueryItem(name: key, value: String(describing: value))]
    }
}

public extension URL {
    func with(query: Query) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let newItems = query
            .sorted { $0.0 < $1.0 }
            .flatMap(makeQueryItems)
        guard newItems.isEmpty == false else { return self }
        let existingItems = components?.queryItems ?? []
        components?.queryItems = existingItems + newItems
        return components?.url
    }
}

import Foundation

extension Collection where Indices.Element == Int {
    subscript (safe index: Int) -> Element? {
        assert(indices.contains(index))
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

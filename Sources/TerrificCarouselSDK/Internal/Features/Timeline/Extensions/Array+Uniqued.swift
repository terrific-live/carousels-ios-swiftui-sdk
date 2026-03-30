//
//  Array+Uniqued.swift
//  CarouselDemo
//

import Foundation

extension Array {
    /// Returns an array with duplicate elements removed, preserving order.
    /// Uses a key path to determine uniqueness.
    /// - Parameter keyPath: The key path to use for determining uniqueness
    /// - Returns: An array with only the first occurrence of each unique element
    func uniqued<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            let key = element[keyPath: keyPath]
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
}

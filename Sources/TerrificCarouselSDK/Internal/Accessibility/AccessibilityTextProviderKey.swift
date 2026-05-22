//
//  AccessibilityTextProviderKey.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - Environment Key
struct AccessibilityTextProviderKey: EnvironmentKey {
    static let defaultValue: AccessibilityTextProvider = LocalizedAccessibilityTextProvider()
}

// MARK: - Environment Values Extension
extension EnvironmentValues {
    var accessibilityText: AccessibilityTextProvider {
        get { self[AccessibilityTextProviderKey.self] }
        set { self[AccessibilityTextProviderKey.self] = newValue }
    }
}

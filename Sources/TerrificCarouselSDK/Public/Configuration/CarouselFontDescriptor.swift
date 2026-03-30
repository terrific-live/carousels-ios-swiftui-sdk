//
//  CarouselFontDescriptor.swift
//  CarouselDemo
//
//  Font descriptor for SDK configuration.
//

import SwiftUI

// MARK: - CarouselFontDescriptor
/// Describes a font configuration that can be converted to a SwiftUI Font.
/// This struct is Equatable and Sendable, making it suitable for SDK configuration.
public struct CarouselFontDescriptor: Equatable, Sendable {

    // MARK: - FontFamily
    /// The font family to use
    public enum FontFamily: Equatable, Sendable {
        /// System font (San Francisco on Apple platforms)
        case system
        /// Custom font with the specified family name.
        /// The font must be bundled in the app using the SDK.
        case custom(String)
    }

    // MARK: - Properties
    /// The font family
    public let family: FontFamily
    /// The font size in points
    public let size: CGFloat
    /// The font weight
    public let weight: Font.Weight

    // MARK: - Init
    public init(
        family: FontFamily = .system,
        size: CGFloat,
        weight: Font.Weight = .regular
    ) {
        self.family = family
        self.size = size
        self.weight = weight
    }

    // MARK: - Convenience Initializers
    /// Creates a system font descriptor with the specified size and weight
    public static func system(size: CGFloat, weight: Font.Weight = .regular) -> CarouselFontDescriptor {
        CarouselFontDescriptor(family: .system, size: size, weight: weight)
    }

    /// Creates a custom font descriptor with the specified family name and size.
    /// Note: For custom fonts, include the weight variant in the font name
    /// (e.g., "Avenir-Heavy", "Avenir-Bold"). The weight parameter is ignored for custom fonts.
    public static func custom(_ name: String, size: CGFloat) -> CarouselFontDescriptor {
        CarouselFontDescriptor(family: .custom(name), size: size, weight: .regular)
    }

    // MARK: - Font Conversion
    /// Converts the descriptor to a SwiftUI Font
    public func toFont() -> Font {
        switch family {
        case .system:
            return .system(size: size, weight: weight)
        case .custom(let name):
            // Weight is embedded in the custom font name (e.g., "Avenir-Heavy")
            return .custom(name, size: size)
        }
    }
}

//
//  CarouselConfigDTO.swift
//  CarouselDemo
//

import Foundation

// MARK: - CarouselConfigDTO
/// Configuration for the carousel from the API
struct CarouselConfigDTO: Codable, Equatable {
    /// Format string for timestamps (e.g., "{DD}/{MM}/{YYYY} - {hh}h{mm}")
    let timestampFormat: String?
    /// Whether to show the carousel name label
    let showName: Bool?
    /// Whether to auto-play the carousel
    let carouselAutoPlay: Bool?
    /// Auto-play interval in seconds
    let carouselAutoPlayInterval: Double?
    /// Carousel name/title to display
    let name: String?
    /// Whether to show timestamp labels on assets
    let showTimestamps: Bool?
    /// Whether to use asset brandName as product name in ProductView
    let mapBrandNameToProductName: Bool?
}

// MARK: - Timestamp Formatting
extension CarouselConfigDTO {

    /// Formats a date using the configured timestamp format
    /// - Parameter date: The date to format
    /// - Returns: Formatted string, or default format if no format specified
    func formatTimestamp(_ date: Date) -> String {
        guard let format = timestampFormat, !format.isEmpty else {
            return Self.defaultFormattedTimestamp(date)
        }
        return Self.formatDate(date, with: format)
    }

    /// Default timestamp formatting (e.g., "05.02.26 | 17:05")
    private static func defaultFormattedTimestamp(_ date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short

        let time = timeFormatter.string(from: date)
        let dateStr = dateFormatter.string(from: date)

        return "\(dateStr) | \(time)"
    }

    /// Formats date using custom format string with placeholders
    /// Supports: {DD}, {MM}, {YYYY}, {YY}, {hh}, {mm}, {ss}
    private static func formatDate(_ date: Date, with format: String) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        var result = format

        // Day
        if let day = components.day {
            result = result.replacingOccurrences(of: "{DD}", with: String(format: "%02d", day))
        }

        // Month
        if let month = components.month {
            result = result.replacingOccurrences(of: "{MM}", with: String(format: "%02d", month))
        }

        // Year
        if let year = components.year {
            result = result.replacingOccurrences(of: "{YYYY}", with: String(year))
            result = result.replacingOccurrences(of: "{YY}", with: String(format: "%02d", year % 100))
        }

        // Hour
        if let hour = components.hour {
            result = result.replacingOccurrences(of: "{hh}", with: String(format: "%02d", hour))
        }

        // Minute
        if let minute = components.minute {
            result = result.replacingOccurrences(of: "{mm}", with: String(format: "%02d", minute))
        }

        // Second
        if let second = components.second {
            result = result.replacingOccurrences(of: "{ss}", with: String(format: "%02d", second))
        }

        return result
    }
}

// MARK: - Default Instance
extension CarouselConfigDTO {
    /// Default configuration when none is provided by API
    static let `default` = CarouselConfigDTO(
        timestampFormat: nil,
        showName: false,
        carouselAutoPlay: false,
        carouselAutoPlayInterval: 4.0,
        name: nil,
        showTimestamps: true,
        mapBrandNameToProductName: false
    )
}

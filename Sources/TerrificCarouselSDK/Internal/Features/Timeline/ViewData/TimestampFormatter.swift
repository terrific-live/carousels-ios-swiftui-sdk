//
//  TimestampFormatter.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - TimestampFormatter
/// Formats asset timestamps using either a custom API format string or a locale-aware default.
enum TimestampFormatter {

    /// Formats a date using an optional custom format string from the API.
    /// - Parameters:
    ///   - date: The date to format
    ///   - formatString: Custom format with placeholders (e.g., "{DD}/{MM}/{YYYY} - {hh}h{mm}"), or nil for default
    /// - Returns: Formatted timestamp string
    static func format(_ date: Date, with formatString: String?) -> String {
        guard let formatString, !formatString.isEmpty else {
            return defaultFormat(date)
        }
        return customFormat(date, with: formatString)
    }

    /// Default timestamp formatting (e.g., "05.02.26 | 17:05")
    private static func defaultFormat(_ date: Date) -> String {
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

    /// Formats date using custom format string with placeholders.
    /// Supports: {DD}, {MM}, {YYYY}, {YY}, {hh}, {mm}, {ss}
    private static func customFormat(_ date: Date, with format: String) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        var result = format

        if let day = components.day {
            result = result.replacingOccurrences(of: "{DD}", with: String(format: "%02d", day))
        }

        if let month = components.month {
            result = result.replacingOccurrences(of: "{MM}", with: String(format: "%02d", month))
        }

        if let year = components.year {
            result = result.replacingOccurrences(of: "{YYYY}", with: String(year))
            result = result.replacingOccurrences(of: "{YY}", with: String(format: "%02d", year % 100))
        }

        if let hour = components.hour {
            result = result.replacingOccurrences(of: "{hh}", with: String(format: "%02d", hour))
        }

        if let minute = components.minute {
            result = result.replacingOccurrences(of: "{mm}", with: String(format: "%02d", minute))
        }

        if let second = components.second {
            result = result.replacingOccurrences(of: "{ss}", with: String(format: "%02d", second))
        }

        return result
    }
}

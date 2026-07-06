//
//  AnalyticsConfiguration.swift
//  CarouselDemo
//

import Foundation

// MARK: - AnalyticsConfiguration
struct AnalyticsConfiguration {
    // MARK: - Static Properties

    static var isAnalyticsEnabled: Bool {
#if DEBUG
        return false
#else
        return true
#endif
    }

    let baseURL: URL
    let storeId: String
    let userId: String

    // MARK: - Init
    init(
        baseURL: URL,
        storeId: String,
        userId: String
    ) {
        self.baseURL = baseURL
        self.storeId = storeId
        self.userId = userId
    }

    // MARK: - Computed
    var userAgent: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "Unknown"
            }
        }
        let deviceName = Self.deviceNameMap[identifier] ?? identifier
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        return "\(deviceName) (iOS; \(osVersion)) AppVersion/\(appVersion) Build/\(buildNumber)"
    }

    // MARK: - Device Name Mapping
    private static let deviceNameMap: [String: String] = [
        // iPhone
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone9,1": "iPhone 7", "iPhone9,3": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus", "iPhone9,4": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8", "iPhone10,4": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus", "iPhone10,5": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X", "iPhone10,6": "iPhone X",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max", "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd gen)",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,6": "iPhone SE (3rd gen)",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",
        // iPad
        "iPad13,18": "iPad (10th gen)",
        "iPad13,19": "iPad (10th gen)",
        "iPad14,1": "iPad mini (6th gen)",
        "iPad14,2": "iPad mini (6th gen)",
        "iPad14,3": "iPad Pro 11-inch (4th gen)",
        "iPad14,4": "iPad Pro 11-inch (4th gen)",
        "iPad14,5": "iPad Pro 12.9-inch (6th gen)",
        "iPad14,6": "iPad Pro 12.9-inch (6th gen)",
        "iPad14,8": "iPad Air (6th gen)",
        "iPad14,9": "iPad Air (6th gen)",
        "iPad14,10": "iPad Air 13-inch (6th gen)",
        "iPad14,11": "iPad Air 13-inch (6th gen)",
        "iPad16,1": "iPad mini (7th gen)",
        "iPad16,2": "iPad mini (7th gen)",
        "iPad16,3": "iPad Pro 11-inch (5th gen)",
        "iPad16,4": "iPad Pro 11-inch (5th gen)",
        "iPad16,5": "iPad Pro 13-inch (5th gen)",
        "iPad16,6": "iPad Pro 13-inch (5th gen)",
        // Simulator
        "i386": "Simulator",
        "x86_64": "Simulator",
        "arm64": "Simulator",
    ]
}

// MARK: - Factory
extension AnalyticsConfiguration {
    /// Creates analytics configuration using the analytics base URL from API config.
    static func make(
        apiConfig: APIConfiguration,
        terrificUserId: String
    ) -> AnalyticsConfiguration {
        AnalyticsConfiguration(
            baseURL: apiConfig.analyticsBaseURL,
            storeId: apiConfig.storeId,
            userId: terrificUserId
        )
    }
}

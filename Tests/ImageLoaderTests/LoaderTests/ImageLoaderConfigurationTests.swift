//
//  ImageLoaderConfigurationTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImageLoaderConfigurationTests: XCTestCase {

    // MARK: - Default Configuration Tests

    func testDefaultConfiguration() {
        let config = ImageLoaderConfiguration.default

        XCTAssertEqual(config.downloadTimeout, 15.0)
        XCTAssertEqual(config.maxRetryAttempts, 1)
    }

    // MARK: - Aggressive Configuration Tests

    func testAggressiveConfiguration() {
        let config = ImageLoaderConfiguration.aggressive

        XCTAssertEqual(config.downloadTimeout, 10.0)
        XCTAssertEqual(config.maxRetryAttempts, 2)
    }

    // MARK: - Testing Configuration Tests

    func testTestingConfiguration() {
        let config = ImageLoaderConfiguration.testing

        XCTAssertEqual(config.downloadTimeout, 5.0)
        XCTAssertEqual(config.maxRetryAttempts, 0)
    }

    // MARK: - Custom Configuration Tests

    func testCustomConfiguration() {
        let config = ImageLoaderConfiguration(
            downloadTimeout: 30.0,
            maxRetryAttempts: 3
        )

        XCTAssertEqual(config.downloadTimeout, 30.0)
        XCTAssertEqual(config.maxRetryAttempts, 3)
    }

    // MARK: - Sendable Conformance Tests

    func testSendableConformance() async {
        let config = ImageLoaderConfiguration.default

        // Test that configuration can be passed across actor boundaries
        await Task.detached {
            XCTAssertEqual(config.downloadTimeout, 15.0)
        }.value
    }
}

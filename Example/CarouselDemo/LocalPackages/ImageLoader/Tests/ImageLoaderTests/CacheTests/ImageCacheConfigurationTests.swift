//
//  ImageCacheConfigurationTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImageCacheConfigurationTests: XCTestCase {

    // MARK: - Default Configuration Tests

    func testDefaultConfiguration() {
        let config = ImageCacheConfiguration.default

        XCTAssertEqual(config.memoryCountLimit, 100)
        XCTAssertEqual(config.memoryCostLimit, 50 * 1024 * 1024)
        XCTAssertTrue(config.diskCacheEnabled)
        XCTAssertEqual(config.diskCacheSizeLimit, 100 * 1024 * 1024)
        XCTAssertEqual(config.diskCacheAgeLimit, 7 * 24 * 60 * 60)
    }

    // MARK: - Memory Only Configuration Tests

    func testMemoryOnlyConfiguration() {
        let config = ImageCacheConfiguration.memoryOnly

        XCTAssertFalse(config.diskCacheEnabled)
    }

    // MARK: - Testing Configuration Tests

    func testTestingConfiguration() {
        let config = ImageCacheConfiguration.testing

        XCTAssertEqual(config.memoryCountLimit, 10)
        XCTAssertEqual(config.memoryCostLimit, 1 * 1024 * 1024)
        XCTAssertTrue(config.diskCacheEnabled)
        XCTAssertEqual(config.diskCacheSizeLimit, 1 * 1024 * 1024)
        XCTAssertEqual(config.diskCacheAgeLimit, 60)
    }

    // MARK: - Custom Configuration Tests

    func testCustomConfiguration() {
        let config = ImageCacheConfiguration(
            memoryCountLimit: 50,
            memoryCostLimit: 25 * 1024 * 1024,
            diskCacheEnabled: false,
            diskCacheSizeLimit: 50 * 1024 * 1024,
            diskCacheAgeLimit: 3600
        )

        XCTAssertEqual(config.memoryCountLimit, 50)
        XCTAssertEqual(config.memoryCostLimit, 25 * 1024 * 1024)
        XCTAssertFalse(config.diskCacheEnabled)
        XCTAssertEqual(config.diskCacheSizeLimit, 50 * 1024 * 1024)
        XCTAssertEqual(config.diskCacheAgeLimit, 3600)
    }

    // MARK: - Sendable Conformance Tests

    func testSendableConformance() async {
        let config = ImageCacheConfiguration.default

        // Test that configuration can be passed across actor boundaries
        await Task.detached {
            XCTAssertEqual(config.memoryCountLimit, 100)
        }.value
    }
}

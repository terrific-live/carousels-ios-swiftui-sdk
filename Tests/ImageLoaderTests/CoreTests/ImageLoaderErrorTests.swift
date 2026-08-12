//
//  ImageLoaderErrorTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImageLoaderErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func testInvalidURLErrorDescription() {
        let error = ImageLoaderError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid image URL")
    }

    func testLoadFailedErrorDescription() {
        let error = ImageLoaderError.loadFailed
        XCTAssertEqual(error.errorDescription, "Failed to load image")
    }

    func testTimeoutErrorDescription() {
        let error = ImageLoaderError.timeout
        XCTAssertEqual(error.errorDescription, "Image download timed out")
    }

    // MARK: - Equatable Tests

    func testErrorEquality() {
        XCTAssertEqual(ImageLoaderError.invalidURL, ImageLoaderError.invalidURL)
        XCTAssertEqual(ImageLoaderError.loadFailed, ImageLoaderError.loadFailed)
        XCTAssertEqual(ImageLoaderError.timeout, ImageLoaderError.timeout)

        XCTAssertNotEqual(ImageLoaderError.invalidURL, ImageLoaderError.loadFailed)
        XCTAssertNotEqual(ImageLoaderError.invalidURL, ImageLoaderError.timeout)
    }

    // MARK: - LocalizedError Conformance Tests

    func testConformsToLocalizedError() {
        let error: LocalizedError = ImageLoaderError.invalidURL
        XCTAssertNotNil(error.errorDescription)
    }
}

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

    func testHTTPErrorDescription() {
        let error = ImageLoaderError.httpError(statusCode: 404)
        XCTAssertEqual(error.errorDescription, "HTTP error: 404")

        let error500 = ImageLoaderError.httpError(statusCode: 500)
        XCTAssertEqual(error500.errorDescription, "HTTP error: 500")
    }

    // MARK: - Equatable Tests

    func testErrorEquality() {
        XCTAssertEqual(ImageLoaderError.invalidURL, ImageLoaderError.invalidURL)
        XCTAssertEqual(ImageLoaderError.loadFailed, ImageLoaderError.loadFailed)
        XCTAssertEqual(ImageLoaderError.timeout, ImageLoaderError.timeout)
        XCTAssertEqual(ImageLoaderError.httpError(statusCode: 404), ImageLoaderError.httpError(statusCode: 404))

        XCTAssertNotEqual(ImageLoaderError.invalidURL, ImageLoaderError.loadFailed)
        XCTAssertNotEqual(ImageLoaderError.httpError(statusCode: 404), ImageLoaderError.httpError(statusCode: 500))
    }

    // MARK: - LocalizedError Conformance Tests

    func testConformsToLocalizedError() {
        let error: LocalizedError = ImageLoaderError.invalidURL
        XCTAssertNotNil(error.errorDescription)
    }
}

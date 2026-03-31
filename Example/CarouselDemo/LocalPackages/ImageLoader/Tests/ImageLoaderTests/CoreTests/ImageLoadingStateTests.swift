//
//  ImageLoadingStateTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImageLoadingStateTests: XCTestCase {

    // MARK: - State Tests

    func testIdleState() {
        let state = ImageLoadingState.idle
        if case .idle = state {
            // Success
        } else {
            XCTFail("Expected idle state")
        }
    }

    func testLoadingState() {
        let state = ImageLoadingState.loading
        if case .loading = state {
            // Success
        } else {
            XCTFail("Expected loading state")
        }
    }

    func testLoadedState() {
        let image = createTestImage()
        let state = ImageLoadingState.loaded(image)
        if case .loaded(let loadedImage) = state {
            XCTAssertTrue(loadedImage === image)
        } else {
            XCTFail("Expected loaded state")
        }
    }

    func testFailedState() {
        let error = ImageLoaderError.loadFailed
        let state = ImageLoadingState.failed(error)
        if case .failed = state {
            // Success
        } else {
            XCTFail("Expected failed state")
        }
    }

    // MARK: - Equatable Tests

    func testIdleEquality() {
        XCTAssertEqual(ImageLoadingState.idle, ImageLoadingState.idle)
    }

    func testLoadingEquality() {
        XCTAssertEqual(ImageLoadingState.loading, ImageLoadingState.loading)
    }

    func testLoadedEqualityWithSameImage() {
        let image = createTestImage()
        XCTAssertEqual(ImageLoadingState.loaded(image), ImageLoadingState.loaded(image))
    }

    func testLoadedInequalityWithDifferentImages() {
        let image1 = createTestImage()
        let image2 = createTestImage()
        XCTAssertNotEqual(ImageLoadingState.loaded(image1), ImageLoadingState.loaded(image2))
    }

    func testFailedEquality() {
        let error1 = ImageLoaderError.loadFailed
        let error2 = ImageLoaderError.timeout
        XCTAssertEqual(ImageLoadingState.failed(error1), ImageLoadingState.failed(error2))
    }

    func testDifferentStatesAreNotEqual() {
        let image = createTestImage()
        XCTAssertNotEqual(ImageLoadingState.idle, ImageLoadingState.loading)
        XCTAssertNotEqual(ImageLoadingState.idle, ImageLoadingState.loaded(image))
        XCTAssertNotEqual(ImageLoadingState.loading, ImageLoadingState.failed(ImageLoaderError.loadFailed))
    }
}

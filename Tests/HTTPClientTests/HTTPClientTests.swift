import XCTest
@testable import HTTPClient

final class HTTPClientTests: XCTestCase {

    func testClientInitialization() {
        let client = Client(base: "https://api.example.com")
        XCTAssertNotNil(client)
    }
}

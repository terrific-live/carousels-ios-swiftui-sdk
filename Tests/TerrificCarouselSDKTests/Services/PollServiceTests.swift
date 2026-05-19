//
//  PollServiceTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
import HTTPClient
@testable import TerrificCarouselSDK

final class PollServiceTests: XCTestCase {

    // MARK: - Properties
    private var sut: PollServiceImpl!
    private var mockTransport: MockNetworkTransport!
    private var client: Client!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockTransport = MockNetworkTransport()
        client = Client(
            base: "https://api.test.com",
            version: nil,
            transport: mockTransport
        )

        let config = APIConfiguration(
            storeId: "test-store",
            carouselId: "test-carousel"
        )

        sut = PollServiceImpl(
            client: client,
            configuration: config,
            terrificUserId: "user-123"
        )
    }

    override func tearDown() {
        sut = nil
        client = nil
        mockTransport = nil
        super.tearDown()
    }

    // MARK: - Request Construction Tests

    func testVote_constructsCorrectPath() async throws {
        // Given
        let options = [PollOptionDTO(text: "Red", numberOfVotes: 11)]
        mockTransport.stubSuccess(options)

        // When
        _ = try await sut.vote(
            pollId: "poll-123",
            questionId: "q-1",
            vote: "Red"
        )

        // Then
        let request = mockTransport.lastRequest
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.url?.path.contains("/api/v1/stores/test-store/poll/poll-123") ?? false)
    }

    func testVote_usesPostMethod() async throws {
        // Given
        let options = [PollOptionDTO(text: "Red", numberOfVotes: 11)]
        mockTransport.stubSuccess(options)

        // When
        _ = try await sut.vote(
            pollId: "poll-123",
            questionId: "q-1",
            vote: "Red"
        )

        // Then
        XCTAssertEqual(mockTransport.lastRequest?.httpMethod, "POST")
    }

    func testVote_includesJsonContentType() async throws {
        // Given
        let options = [PollOptionDTO(text: "Red", numberOfVotes: 11)]
        mockTransport.stubSuccess(options)

        // When
        _ = try await sut.vote(
            pollId: "poll-123",
            questionId: "q-1",
            vote: "Red"
        )

        // Then
        let contentType = mockTransport.lastRequest?.value(forHTTPHeaderField: "Content-Type")
        XCTAssertEqual(contentType, "application/json")
    }

    func testVote_includesBodyWithVoteData() async throws {
        // Given
        let options = [PollOptionDTO(text: "Red", numberOfVotes: 11)]
        mockTransport.stubSuccess(options)

        // When
        _ = try await sut.vote(
            pollId: "poll-123",
            questionId: "q-1",
            vote: "Red"
        )

        // Then
        let bodyData = mockTransport.lastRequest?.httpBody
        XCTAssertNotNil(bodyData)

        if let bodyData = bodyData {
            let bodyJson = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
            XCTAssertEqual(bodyJson?["questionId"] as? String, "q-1")
            XCTAssertEqual(bodyJson?["userId"] as? String, "user-123")
            XCTAssertEqual(bodyJson?["vote"] as? String, "Red")
        }
    }

    // MARK: - Response Handling Tests

    func testVote_returnsUpdatedOptions() async throws {
        // Given
        let options = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]
        mockTransport.stubSuccess(options)

        // When
        let result = try await sut.vote(
            pollId: "poll-123",
            questionId: "q-1",
            vote: "Red"
        )

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].text, "Red")
        XCTAssertEqual(result[0].numberOfVotes, 11)
        XCTAssertEqual(result[1].text, "Blue")
        XCTAssertEqual(result[1].numberOfVotes, 20)
    }

    func testVote_returnsEmptyArrayWhenNilResponse() async throws {
        // Given - transport returns nil data
        mockTransport.stubbedData = nil
        mockTransport.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result = try await sut.vote(
            pollId: "poll-123",
            questionId: "q-1",
            vote: "Red"
        )

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Error Handling Tests

    func testVote_throwsOnNetworkError() async {
        // Given
        let networkError = NSError(domain: "Network", code: -1009)
        mockTransport.stubError(networkError)

        // When/Then
        do {
            _ = try await sut.vote(
                pollId: "poll-123",
                questionId: "q-1",
                vote: "Red"
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testVote_callsClientOnce() async throws {
        // Given
        let options = [PollOptionDTO(text: "Red", numberOfVotes: 11)]
        mockTransport.stubSuccess(options)

        // When
        _ = try await sut.vote(
            pollId: "poll-123",
            questionId: "q-1",
            vote: "Red"
        )

        // Then
        XCTAssertEqual(mockTransport.sendCallCount, 1)
    }
}

@preconcurrency import XCTest
import hCore

@testable import Chat

@MainActor
final class TestChatViewModelCrossSell: XCTestCase {
    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: ConversationClient.self)
    }

    func testServiceCarriesCrossSellGateFromClient() async throws {
        MockData.createMockConversationClient(showCrossSales: true)
        let data = try await ConversationService(conversationId: "conv-1").getNewMessages()
        XCTAssertTrue(data.showCrossSales)
    }

    func testServiceReportsCrossSellGateAsFalseWhenClientDoes() async throws {
        MockData.createMockConversationClient(showCrossSales: false)
        let data = try await ConversationService(conversationId: "conv-1").getNewMessages()
        XCTAssertFalse(data.showCrossSales)
    }

    func testHideCrossSalesForwardsTheConversationId() async throws {
        let client = MockData.createMockConversationClient()
        try await ConversationService(conversationId: "conv-1").hideCrossSales()
        XCTAssertEqual(client.hiddenCrossSalesIds, ["conv-1"])
    }

    func testHideCrossSalesIsANoOpBeforeTheFirstMessage() async throws {
        let client = MockData.createMockConversationClient()
        // Nothing exists server-side until the member sends their first message, so this
        // must not reach the client rather than hiding some other conversation's prompt.
        try await NewConversationService().hideCrossSales()
        XCTAssertTrue(client.hiddenCrossSalesIds.isEmpty)
    }
}

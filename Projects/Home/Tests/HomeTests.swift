import XCTest
import hCore

@testable import Home

final class HomeTests: XCTestCase {
    weak var sut: MockHomeService?

    override func setUp() {
        super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: HomeClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testGetImportantMessagesSuccess() async {
        let linkUrl = URL(string: "https://hedvig.com")!
        let importantMessages: [Home.ImportantMessage] = [
            .init(
                id: "id1",
                message: "This is an important message",
                linkInfo: nil
            ),
            .init(
                id: "id2",
                message: "This is another important message with link",
                linkInfo: .init(link: linkUrl, text: "link")
            ),
        ]

        let mockService = MockData.createMockHomeService(
            fetchImportantMessages: { importantMessages }
        )
        self.sut = mockService

        let respondedMessages = try! await mockService.getImportantMessages()
        assert(respondedMessages == importantMessages)
    }

    func testGetMemberStateSuccess() async {
        let memberState: MemberState = .init(
            contracts: [
                .init(
                    upcomingRenewal: nil,
                    displayName: "contract display name"
                )
            ],
            contractState: .active,
            futureState: .none
        )

        let mockService = MockData.createMockHomeService(
            fetchMemberState: { memberState }
        )
        self.sut = mockService

        let respondedMemberState = try! await mockService.getMemberState()
        assert(respondedMemberState.contractState == memberState.contractState)
        assert(respondedMemberState.contracts == memberState.contracts)
        assert(respondedMemberState.futureState == memberState.futureState)
    }

    func testGetQuickActionsSuccess() async {
        let quickActions: [QuickAction] = [
            .cancellation, .travelInsurance, .connectPayments, .editCoInsured,
        ]

        let mockService = MockData.createMockHomeService(
            fetchQuickActions: { quickActions }
        )
        self.sut = mockService

        let respondedQuickActions = try! await mockService.getQuickActions()
        assert(respondedQuickActions == quickActions)
    }

    func testGetLastMessagesDatesSuccess() async {

        let dateOfLastMessage = "2024-07-16".localDateToDate!

        let lastMessages: [String: Date] = [
            "message1": Date(),
            "message2": dateOfLastMessage,
        ]

        let mockService = MockData.createMockHomeService(
            fetchLastMessagesDates: { lastMessages }
        )
        self.sut = mockService

        let respondedLastMessages = try! await mockService.getLastMessagesDates()
        assert(respondedLastMessages == lastMessages)
    }
}

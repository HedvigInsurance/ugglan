@preconcurrency import XCTest
import hCore

@testable import SubmitClaim

@MainActor
final class FetchEntrypointsTests: XCTestCase {
    weak var sut: MockFetchEntrypointsService?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: hFetchEntrypointsClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testFetchEntrypointsSuccess() async {
        let entrypoints: [ClaimEntryPointGroupResponseModel] = [
            .init(
                id: "id1",
                displayName: "display name",
                entrypoints: [
                    .init(
                        id: "entrypoint1",
                        displayName: "entrypoint",
                        options: [
                            .init(
                                id: "entrypoint option 1",
                                displayName: "entrypoint option 1"
                            ),
                            .init(
                                id: "entrypoint option 2",
                                displayName: "entrypoint option 2"
                            ),
                        ]
                    )
                ]
            )
        ]

        let mockService = MockData.createMockFetchEntrypointsService(
            fetchEntrypoints: { entrypoints })
        sut = mockService

        let respondedEntrypoints = try! await mockService.fetchEntrypoints()
        assert(respondedEntrypoints == entrypoints)
        assert(respondedEntrypoints.count == entrypoints.count)
        assert(
            respondedEntrypoints.first?.entrypoints.first?.displayName
                == entrypoints.first?.entrypoints.first?.displayName
        )
    }
}

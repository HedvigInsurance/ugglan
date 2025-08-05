@preconcurrency import XCTest
import hCore

@testable import Claims

@MainActor
final class FetchClaimsTests: XCTestCase {
    weak var sut: MockFetchClaimsService?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hFetchClaimsClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testFetchClaimsSuccess() async {
        let claims: Claims = .init(
            claims: [],
            claimsActive: [
                .init(
                    id: "id1",
                    status: .beingHandled,
                    outcome: .none,
                    submittedAt: "2024-07-27",
                    signedAudioURL: nil,
                    memberFreeText: nil,
                    payoutAmount: nil,
                    targetFileUploadUri: "",
                    claimType: "",
                    productVariant: nil,
                    conversation: nil,
                    appealInstructionsUrl: nil,
                    isUploadingFilesEnabled: false,
                    showClaimClosedFlow: false,
                    infoText: nil,
                    displayItems: []
                ),
                .init(
                    id: "id2",
                    status: .beingHandled,
                    outcome: .paid,
                    submittedAt: "2024-07-01",
                    signedAudioURL: nil,
                    memberFreeText: nil,
                    payoutAmount: nil,
                    targetFileUploadUri: "",
                    claimType: "",
                    productVariant: nil,
                    conversation: nil,
                    appealInstructionsUrl: nil,
                    isUploadingFilesEnabled: false,
                    showClaimClosedFlow: false,
                    infoText: nil,
                    displayItems: []
                ),
            ],
            claimsHistory: [
                .init(
                    id: "id3",
                    status: .closed,
                    outcome: .paid,
                    submittedAt: "2024-07-01",
                    signedAudioURL: nil,
                    memberFreeText: nil,
                    payoutAmount: nil,
                    targetFileUploadUri: "",
                    claimType: "",
                    productVariant: nil,
                    conversation: nil,
                    appealInstructionsUrl: nil,
                    isUploadingFilesEnabled: false,
                    showClaimClosedFlow: false,
                    infoText: nil,
                    displayItems: []
                )
            ]
        )

        let mockService = MockData.createMockFetchClaimService(
            fetch: { claims }
        )
        sut = mockService

        let respondedClaims = try! await mockService.fetch()
        assert(respondedClaims == claims)
    }

    func testFetchFilesSuccess() async {
        let files: [String: [hCore.File]] = [
            "files1": [
                File(
                    id: "file1",
                    size: 2.0,
                    mimeType: .SVG,
                    name: "file1",
                    source: .url(url: URL(string: "https://hedvig.com")!, mimeType: .PDF)
                )
            ],
            "file2": [
                File(
                    id: "file1",
                    size: 2.0,
                    mimeType: .SVG,
                    name: "file1",
                    source: .url(url: URL(string: "https://hedvig.com")!, mimeType: .PDF)
                ),
                File(
                    id: "file2",
                    size: 5.0,
                    mimeType: .JPG,
                    name: "file2",
                    source: .localFile(results: nil)
                ),
            ],
        ]

        let mockService = MockData.createMockFetchClaimService(
            fetchFiles: { files }
        )
        sut = mockService

        let respondedFiles = try! await mockService.fetchFiles()
        assert(respondedFiles == files)
    }
}

import Foundation
import TestDependencies
import Testing
import hCore

@testable import Claims

@Suite(.serialized)
@MainActor
final class FetchClaimsTests {
    // Serialized because every test registers and removes hFetchClaimsClient in Dependencies.shared.
    private weak var sut: MockFetchClaimsService?

    init() {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    // Test bodies are scoped so their locals are released before this check runs.
    private func expectServiceReleased() async {
        Dependencies.shared.remove(for: hFetchClaimsClient.self)
        await delay(0.0000001)
        #expect(sut == nil, "the mock service must not outlive its dependency registration")
    }

    @Test
    func fetchActiveClaimsSuccess() async {
        let activeClaims: [ClaimModel] = [
            .init(
                id: "id1",
                status: .beingHandled,
                outcome: .none,
                submittedAt: "2024-07-27".localDateToDate,
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
                submittedAt: "2024-07-01".localDateToDate,
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
        ]

        await recordingErrors {
            let mockService = MockData.createMockFetchClaimService(
                fetchActive: { activeClaims }
            )
            sut = mockService

            let respondedClaims = try await mockService.fetchActive()
            #expect(respondedClaims == activeClaims)
        }

        await expectServiceReleased()
    }

    @Test
    func fetchHistoryClaimsSuccess() async {
        let historyClaims: [ClaimModel] = [
            .init(
                id: "id3",
                status: .closed,
                outcome: .paid,
                submittedAt: "2024-07-01".localDateToDate,
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

        await recordingErrors {
            let mockService = MockData.createMockFetchClaimService(
                fetchHistory: { historyClaims }
            )
            sut = mockService

            let respondedClaims = try await mockService.fetchHistory()
            #expect(respondedClaims == historyClaims)
        }

        await expectServiceReleased()
    }

    @Test
    func fetchFilesSuccess() async {
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

        await recordingErrors {
            let mockService = MockData.createMockFetchClaimService(
                fetchFiles: { files }
            )
            sut = mockService

            let respondedFiles = try await mockService.fetchFiles()
            #expect(respondedFiles == files)
        }

        await expectServiceReleased()
    }

    @Test
    func fetchActiveClaimsIncludesPartnerClaims() async {
        let regularClaim = ClaimModel(
            id: "regular-1",
            status: .beingHandled,
            outcome: nil,
            submittedAt: "2026-04-15".localDateToDate,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Broken phone",
            productVariant: nil,
            conversation: nil,
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: false,
            showClaimClosedFlow: false,
            infoText: nil,
            displayItems: []
        )

        let partnerClaim = ClaimModel(
            id: "partner-1",
            status: .beingHandled,
            outcome: nil,
            submittedAt: "2026-04-20".localDateToDate,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Car damage",
            productVariant: nil,
            conversation: nil,
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: false,
            showClaimClosedFlow: false,
            infoText: nil,
            displayItems: [],
            isPartnerClaim: true
        )

        await recordingErrors {
            let mockService = MockData.createMockFetchClaimService(
                fetchActive: { [partnerClaim, regularClaim] }
            )
            sut = mockService

            let respondedClaims = try await mockService.fetchActive()
            #expect(respondedClaims.count == 2)
            #expect(respondedClaims.contains(where: { $0.isPartnerClaim }))
            #expect(respondedClaims.first(where: { $0.isPartnerClaim })?.claimType == "Car damage")
        }

        await expectServiceReleased()
    }

    @Test
    func fetchClaimInProgressSuccess() async {
        await recordingErrors {
            let expected = ClaimInProgressModel(
                id: "1",
                createdAt: try #require("2026-05-01".localDateToDate),
                title: "Continue where you stopped"
            )

            let mockService = MockData.createMockFetchClaimService(
                fetchClaimInProgress: { expected }
            )
            sut = mockService

            let response = try await mockService.getClaimInProgress()
            #expect(response == expected)
            #expect(mockService.events.contains(.getClaimInProgress))
        }

        await expectServiceReleased()
    }

    @Test
    func fetchClaimInProgressReturnsNilWhenNoDraft() async {
        await recordingErrors {
            let mockService = MockData.createMockFetchClaimService(
                fetchClaimInProgress: { nil }
            )
            sut = mockService

            let response = try await mockService.getClaimInProgress()
            #expect(response == nil)
            #expect(mockService.events.contains(.getClaimInProgress))
        }

        await expectServiceReleased()
    }

    @Test
    func fetchClaimInProgressPropagatesError() async {
        do {
            let mockService = MockData.createMockFetchClaimService(
                fetchClaimInProgress: { throw ClaimsError.error }
            )
            sut = mockService

            await #expect(throws: ClaimsError.self) {
                try await mockService.getClaimInProgress()
            }
        }

        await expectServiceReleased()
    }

    @Test
    func partnerClaimModelProperties() {
        let partnerClaim = ClaimModel(
            id: "partner-1",
            status: .beingHandled,
            outcome: nil,
            submittedAt: "2026-04-20".localDateToDate,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "Car damage",
            productVariant: nil,
            conversation: nil,
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: false,
            showClaimClosedFlow: false,
            infoText: nil,
            displayItems: [],
            isPartnerClaim: true
        )

        #expect(partnerClaim.isPartnerClaim)
        #expect(partnerClaim.conversation == nil)
        #expect(partnerClaim.signedAudioURL == nil)
        #expect(partnerClaim.isUploadingFilesEnabled == false)
        #expect(partnerClaim.showClaimClosedFlow == false)
    }
}

@preconcurrency import XCTest
import hCore

@testable import Claims

@MainActor
final class FetchClaimDetailsTests: XCTestCase {
    override func tearDown() async throws {
        Dependencies.shared.remove(for: hFetchClaimDetailsClient.self)
    }

    func testGetRegularClaimSucceeds() async throws {
        let expectedClaim = ClaimModel(
            id: "regular-1",
            status: .beingHandled,
            outcome: nil,
            submittedAt: nil,
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

        let mock = MockFetchClaimDetailsService(
            fetchClaimDetails: { _ in expectedClaim }
        )
        Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in mock })

        let service = FetchClaimDetailsService(id: "regular-1")
        let claim = try await service.get()
        XCTAssertEqual(claim.id, "regular-1")
        XCTAssertFalse(claim.isPartnerClaim)
        XCTAssertEqual(mock.getCallCount, 1)
        XCTAssertEqual(mock.getPartnerClaimCallCount, 0)
    }

    func testGetRegularClaimNotFoundFallsBackToPartnerClaim() async throws {
        let expectedPartnerClaim = ClaimModel(
            id: "partner-1",
            status: .beingHandled,
            outcome: nil,
            submittedAt: nil,
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

        let mock = MockFetchClaimDetailsService(
            fetchClaimDetails: { _ in throw FetchClaimDetailsError.noClaimFound },
            fetchPartnerClaimDetails: { _ in expectedPartnerClaim }
        )
        Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in mock })

        let service = FetchClaimDetailsService(id: "partner-1")
        let claim = try await service.getWithPartnerFallback()
        XCTAssertEqual(claim.id, "partner-1")
        XCTAssertTrue(claim.isPartnerClaim)
        XCTAssertEqual(mock.getCallCount, 1)
        XCTAssertEqual(mock.getPartnerClaimCallCount, 1)
    }

    func testGetRegularClaimNetworkErrorDoesNotFallBack() async throws {
        let mock = MockFetchClaimDetailsService(
            fetchClaimDetails: { _ in throw FetchClaimDetailsError.serviceError(message: "Network error") },
            fetchPartnerClaimDetails: { _ in
                XCTFail("Should not attempt partner claim fetch on network error")
                throw FetchClaimDetailsError.noClaimFound
            }
        )
        Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in mock })

        let service = FetchClaimDetailsService(id: "any-id")
        do {
            _ = try await service.getWithPartnerFallback()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(mock.getCallCount, 1)
            XCTAssertEqual(mock.getPartnerClaimCallCount, 0)
        }
    }
}

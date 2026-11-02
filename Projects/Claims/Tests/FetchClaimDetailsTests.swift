import TestDependencies
import Testing
import hCore

@testable import Claims

@Suite(.serialized)
@MainActor
final class FetchClaimDetailsTests {
    // Serialized because every test registers and removes hFetchClaimDetailsClient in Dependencies.shared.

    // Bodies that can throw are scoped in recordingErrors so this cleanup still runs.
    private func removeRegistration() {
        Dependencies.shared.remove(for: hFetchClaimDetailsClient.self)
    }

    @Test
    func getRegularClaimSucceeds() async {
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

        await recordingErrors {
            let service = FetchClaimDetailsService(id: "regular-1")
            let claim = try await service.get()
            #expect(claim.id == "regular-1")
            #expect(claim.isPartnerClaim == false)
            #expect(mock.getCallCount == 1)
            #expect(mock.getPartnerClaimCallCount == 0)
        }

        removeRegistration()
    }

    @Test
    func getRegularClaimNotFoundFallsBackToPartnerClaim() async {
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

        await recordingErrors {
            let service = FetchClaimDetailsService(id: "partner-1")
            let claim = try await service.getWithPartnerFallback()
            #expect(claim.id == "partner-1")
            #expect(claim.isPartnerClaim)
            #expect(mock.getCallCount == 1)
            #expect(mock.getPartnerClaimCallCount == 1)
        }

        removeRegistration()
    }

    @Test
    func getRegularClaimNetworkErrorDoesNotFallBack() async {
        let mock = MockFetchClaimDetailsService(
            fetchClaimDetails: { _ in throw FetchClaimDetailsError.serviceError(message: "Network error") },
            fetchPartnerClaimDetails: { _ in
                Issue.record("Should not attempt partner claim fetch on network error")
                throw FetchClaimDetailsError.noClaimFound
            }
        )
        Dependencies.shared.add(module: Module { () -> hFetchClaimDetailsClient in mock })

        let service = FetchClaimDetailsService(id: "any-id")
        await #expect(throws: FetchClaimDetailsError.self) {
            try await service.getWithPartnerFallback()
        }
        #expect(mock.getCallCount == 1)
        #expect(mock.getPartnerClaimCallCount == 0)

        removeRegistration()
    }
}

import hCore

public class FetchClaimDetailsClientDemo: hFetchClaimDetailsClient {
    public init() {}
    public func get(for _: String) async throws -> ClaimModel {
        .init(
            id: "1",
            status: .submitted,
            outcome: .none,
            submittedAt: nil,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "",
            productVariant: nil,
            conversation: nil,
            appealInstructionsUrl: "If you have more receipts related to this claim, you can upload more on this page.",
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text",
            displayItems: []
        )
    }

    public func getPartnerClaim(for _: String) async throws -> ClaimModel {
        .init(
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
            displayItems: [
                .init(displayTitle: "Damage date", displayValue: "20 Apr 2026"),
                .init(displayTitle: "Registration number", displayValue: "ABC 123"),
            ],
            isPartnerClaim: true
        )
    }

    public func getFiles(for _: String) async throws -> [File] {
        []
    }

    public func acknowledgeClosedStatus(for _: String) async throws {}
}

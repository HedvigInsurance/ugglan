import hCore

public class FetchClaimDetailsClientDemo: hFetchClaimDetailsClient {
    public init() {}
    public func get(for _: FetchClaimDetailsType) async throws -> ClaimModel {
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

    public func getFiles(for _: FetchClaimDetailsType) async throws -> (claimId: String, files: [hCore.File]) {
        (claimId: "1", files: [])
    }

    public func acknowledgeClosedStatus(claimId _: String) async throws {}
}

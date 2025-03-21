import hCore

public class FetchClaimDetailsClientDemo: hFetchClaimDetailsClient {
    public init() {}
    public func get(for type: FetchClaimDetailsType) async throws -> ClaimModel {
        return .init(
            id: "1",
            status: .submitted,
            outcome: .none,
            submittedAt: nil,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "",
            incidentDate: nil,
            productVariant: nil,
            conversation: nil,
            appealInstructionsUrl: "If you have more receipts related to this claim, you can upload more on this page.",
            isUploadingFilesEnabled: true,
            showClaimClosedFlow: true,
            infoText: "info text"
        )
    }

    public func getFiles(for type: FetchClaimDetailsType) async throws -> (claimId: String, files: [hCore.File]) {
        return (claimId: "1", files: [])
    }

    public func acknowledgeClosedStatus(claimId: String) async throws {}
}

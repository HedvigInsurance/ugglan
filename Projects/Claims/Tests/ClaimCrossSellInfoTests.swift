import XCTest

@testable import Claims

@MainActor
final class ClaimCrossSellInfoTests: XCTestCase {
    private func makeClaim(contractId: String?) -> ClaimModel {
        .init(
            id: "id",
            status: .closed,
            outcome: .none,
            submittedAt: nil,
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
            displayItems: [],
            contractId: contractId
        )
    }

    func testAsCrossSellInfoForwardsContractId() {
        let crossSellInfo = makeClaim(contractId: "contract-123").asCrossSellInfo

        assert(crossSellInfo.contractId == "contract-123")
        assert(crossSellInfo.type == .closedClaim(claimId: "id"))
    }

    func testAsCrossSellInfoWithoutContractId() {
        let crossSellInfo = makeClaim(contractId: nil).asCrossSellInfo

        assert(crossSellInfo.contractId == nil)
        assert(crossSellInfo.type == .closedClaim(claimId: "id"))
    }
}

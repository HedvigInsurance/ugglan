import Foundation
import hCore
import hGraphQL

public protocol hFetchClaimService {
    func get() async throws -> [ClaimModel]
}

class FetchClaimServiceDemo: hFetchClaimService {
    func get() async throws -> [ClaimModel] {
        return [
            ClaimModel(
                id: "claimId",
                status: .beingHandled,
                outcome: .none,
                submittedAt: "2023-11-11",
                closedAt: nil,
                signedAudioURL: "https://filesamples.com/samples/audio/m4a/sample3.m4a",
                type: "associated type",
                memberFreeText: nil,
                payoutAmount: nil,
                files: [
                    .init(
                        id: "imageId1",
                        url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!,
                        mimeType: "image/png",
                        name: "test-image",
                        size: 52176
                    )
                ]
            )
        ]
    }
}

public class FetchClaimServiceOctopus: hFetchClaimService {
    @Inject var octopus: hOctopus

    public init() {}
    public func get() async throws -> [ClaimModel] {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ClaimsQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        let claimData = data.currentMember.claims.map { ClaimModel(claim: $0) }
        return claimData
    }
}
extension ClaimModel {
    fileprivate init(
        claim: OctopusGraphQL.ClaimsQuery.Data.CurrentMember.Claim
    ) {
        self.id = claim.id
        self.status = ClaimStatus(rawValue: claim.status?.rawValue ?? "") ?? .none
        self.outcome = .init(rawValue: claim.outcome?.rawValue ?? "") ?? .none
        self.submittedAt = claim.submittedAt
        self.closedAt = claim.closedAt
        self.signedAudioURL = claim.audioUrl ?? ""
        self.type = claim.associatedTypeOfContract ?? ""
        self.subtitle = ""
        self.memberFreeText = claim.memberFreeText
        self.payoutAmount = MonetaryAmount(optionalFragment: claim.payoutAmount?.fragments.moneyFragment)
        self.files = []
    }
}

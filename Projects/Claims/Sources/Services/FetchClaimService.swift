import Foundation
import hCore
import hGraphQL

public protocol hFetchClaimService {
    func get() async throws -> [ClaimModel]
}

public class FetchClaimServiceDemo: hFetchClaimService {
    public init() {}
    public func get() async throws -> [ClaimModel] {
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
                        mimeType: MimeType.findBy(mimeType: "image/png"),
                        name: "test-image",
                        size: 52176
                    ),
                    .init(
                        id: "imageId2",
                        url: URL(
                            string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png"
                        )!,
                        mimeType: MimeType.findBy(mimeType: "image/png"),
                        name: "test-image",
                        size: 52176
                    ),
                    .init(
                        id: "imageId3",
                        url: URL(string: "https://cdn.pixabay.com/photo/2017/06/21/15/03/example-2427501_1280.png")!,
                        mimeType: MimeType.findBy(mimeType: "image/png"),
                        name: "test-image",
                        size: 52176
                    ),
                    .init(
                        id: "imageId4",
                        url: URL(string: "https://flif.info/example-images/fish.png")!,
                        mimeType: MimeType.findBy(mimeType: "image/png"),
                        name: "test-image",
                        size: 52176
                    ),
                    .init(
                        id: "imageId5",
                        url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
                        mimeType: MimeType.PDF,
                        name: "test-pdf long name it is possible to have it is long name .pdf",
                        size: 52176
                    ),
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

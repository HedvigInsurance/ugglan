import Claims
import Foundation
import hCore
import hGraphQL

public class FetchClaimsClientOctopus: hFetchClaimsClient {
    @Inject var octopus: hOctopus

    public init() {}
    public func get() async throws -> [ClaimModel] {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ClaimsQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        let claimData = data.currentMember.claims.map { ClaimModel(claim: $0.fragments.claimFragment) }
        return claimData
    }
}

@MainActor
extension ClaimModel {
    init(
        claim: OctopusGraphQL.ClaimFragment
    ) {
        self.init(
            id: claim.id,
            status: ClaimStatus(rawValue: claim.status?.rawValue ?? "") ?? .none,
            outcome: .init(rawValue: claim.outcome?.rawValue ?? "") ?? .none,
            submittedAt: claim.submittedAt,
            signedAudioURL: claim.audioUrl ?? "",
            memberFreeText: claim.memberFreeText,
            payoutAmount: MonetaryAmount(optionalFragment: claim.payoutAmount?.fragments.moneyFragment),
            targetFileUploadUri: claim.targetFileUploadUri,
            claimType: claim.claimType ?? "",
            incidentDate: claim.incidentDate,
            productVariant: .init(data: claim.productVariant?.fragments.productVariantFragment),
            conversation: .init(fragment: claim.conversation.fragments.conversationFragment, type: .claim)
        )
    }
}

extension File {
    init(with data: OctopusGraphQL.FileFragment) {
        self.init(
            id: data.id,
            size: 0,
            mimeType: MimeType.findBy(mimeType: data.mimeType),
            name: data.name,
            source: .url(url: URL(string: data.url)!, mimeType: MimeType.findBy(mimeType: data.mimeType))
        )
    }
}

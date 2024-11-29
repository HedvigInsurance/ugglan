import Foundation
import hCore
import hGraphQL

@MainActor
public class hFetchClaimService {
    @Inject var client: hFetchClaimsClient
    public func get() async throws -> [ClaimModel] {
        log.info("hFetchClaimService: get", error: nil, attributes: nil)
        return try await client.get()
    }
}

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
        self.id = claim.id
        self.status = ClaimStatus(rawValue: claim.status?.rawValue ?? "") ?? .none
        self.outcome = .init(rawValue: claim.outcome?.rawValue ?? "") ?? .none
        self.submittedAt = claim.submittedAt
        self.signedAudioURL = claim.audioUrl ?? ""
        self.memberFreeText = claim.memberFreeText
        self.payoutAmount = MonetaryAmount(optionalFragment: claim.payoutAmount?.fragments.moneyFragment)
        self.targetFileUploadUri = claim.targetFileUploadUri
        self.incidentDate = claim.incidentDate
        self.productVariant = .init(data: claim.productVariant?.fragments.productVariantFragment)
        self.claimType = claim.claimType ?? ""
        self.conversation = .init(fragment: claim.conversation.fragments.conversationFragment, type: .claim)
    }
}

extension File {
    init(with data: OctopusGraphQL.FileFragment) {
        self.init(
            id: data.id,
            size: 0,
            mimeType: MimeType.findBy(mimeType: data.mimeType),
            name: data.name,
            source: .url(url: URL(string: data.url)!)
        )
    }
}

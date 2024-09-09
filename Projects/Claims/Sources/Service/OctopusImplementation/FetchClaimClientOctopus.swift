import Foundation
import hCore
import hGraphQL

public class hFetchClaimService {
    @Inject var client: hFetchClaimClient

    public func get() async throws -> [ClaimModel] {
        log.info("hFetchClaimService: get", error: nil, attributes: nil)
        return try await client.get()
    }

    public func getFiles() async throws -> [String: [File]] {
        log.info("hFetchClaimService: getFiles", error: nil, attributes: nil)
        return try await client.getFiles()
    }
}

public class FetchClaimClientOctopus: hFetchClaimClient {
    @Inject var octopus: hOctopus

    public init() {}
    public func get() async throws -> [ClaimModel] {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ClaimsQueryWithConversationQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        let claimData = data.currentMember.claims.map { ClaimModel(claim: $0) }
        return claimData
    }

    public func getFiles() async throws -> [String: [File]] {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ClaimsFilesQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        return data.currentMember.claims
            .reduce(into: [String: [File]]()) { (accumulator, claim) in
                let files = claim.files.compactMap { File(with: $0.fragments.fileFragment) }
                accumulator[claim.id] = files
            }
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
        self.signedAudioURL = claim.audioUrl ?? ""
        self.memberFreeText = claim.memberFreeText
        self.payoutAmount = MonetaryAmount(optionalFragment: claim.payoutAmount?.fragments.moneyFragment)
        self.targetFileUploadUri = claim.targetFileUploadUri
        self.incidentDate = claim.incidentDate
        self.productVariant = .init(data: claim.productVariant?.fragments.productVariantFragment)
        self.claimType = claim.claimType ?? ""
        self.conversation = nil
    }

    fileprivate init(
        claim: OctopusGraphQL.ClaimsQueryWithConversationQuery.Data.CurrentMember.Claim
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

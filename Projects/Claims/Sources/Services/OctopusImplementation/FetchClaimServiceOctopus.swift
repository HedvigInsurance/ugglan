import Foundation
import hCore
import hGraphQL

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
        self.closedAt = claim.closedAt
        self.signedAudioURL = claim.audioUrl ?? ""
        self.type = claim.associatedTypeOfContract ?? ""
        self.subtitle = ""
        self.memberFreeText = claim.memberFreeText
        self.payoutAmount = MonetaryAmount(optionalFragment: claim.payoutAmount?.fragments.moneyFragment)
        self.targetFileUploadUri = claim.targetFileUploadUri
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

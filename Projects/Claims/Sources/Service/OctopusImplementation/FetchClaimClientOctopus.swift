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
        self.id = claim.id
        self.status = claim.status?.asClaimStatus ?? .none
        self.outcome = claim.outcome?.asClaimOutcome
        self.submittedAt = claim.submittedAt
        self.signedAudioURL = claim.audioUrl ?? ""
        self.memberFreeText = claim.memberFreeText
        self.payoutAmount = MonetaryAmount(optionalFragment: claim.payoutAmount?.fragments.moneyFragment)
        self.targetFileUploadUri = claim.targetFileUploadUri
        self.productVariant = .init(data: claim.productVariant?.fragments.productVariantFragment)
        self.claimType = claim.claimType ?? ""
        self.conversation = .init(fragment: claim.conversation.fragments.conversationFragment, type: .claim)
        self.appealInstructionsUrl = claim.appealInstructionsUrl
        self.isUploadingFilesEnabled = claim.isUploadingFilesEnabled
        self.showClaimClosedFlow = claim.showClaimClosedFlow
        self.infoText = claim.infoText
        self.displayItems = claim.displayItems.compactMap({ item in
            let displayValue: String = {
                return item.displayValue.localDateToDate?.displayDateDDMMMYYYYFormat ?? item.displayValue
                    .localDateToIso8601Date?
                    .displayDateDDMMMYYYYFormat ?? item.displayValue
            }()
            return .init(displayTitle: item.displayTitle, displayValue: displayValue)
        })
    }
}

extension GraphQLEnum<OctopusGraphQL.ClaimStatus> {
    fileprivate var asClaimStatus: ClaimModel.ClaimStatus {
        switch self {
        case .case(let status):
            switch status {
            case .created:
                return .submitted
            case .inProgress:
                return .beingHandled
            case .closed:
                return .closed
            case .reopened:
                return .reopened
            }
        case .unknown:
            return ClaimModel.ClaimStatus.none
        }
    }
}

extension GraphQLEnum<OctopusGraphQL.ClaimOutcome> {
    fileprivate var asClaimOutcome: ClaimModel.ClaimOutcome? {
        switch self {
        case .case(let status):
            switch status {
            case .paid:
                return .paid
            case .notCompensated:
                return .notCompensated
            case .notCovered:
                return .notCovered
            case .unresponsive:
                return .unresponsive
            }
        case .unknown:
            return nil
        }
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

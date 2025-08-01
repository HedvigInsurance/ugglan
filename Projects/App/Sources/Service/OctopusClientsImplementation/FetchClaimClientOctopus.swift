import Claims
import Foundation
import hCore
import hGraphQL

class FetchClaimsClientOctopus: hFetchClaimsClient {
    @Inject var octopus: hOctopus

    func get() async throws -> [ClaimModel] {
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
            status: claim.status?.asClaimStatus ?? .none,
            outcome: claim.outcome?.asClaimOutcome,
            submittedAt: claim.submittedAt,
            signedAudioURL: claim.audioUrl ?? "",
            memberFreeText: claim.memberFreeText,
            payoutAmount: MonetaryAmount(optionalFragment: claim.payoutAmount?.fragments.moneyFragment),
            targetFileUploadUri: claim.targetFileUploadUri,
            claimType: claim.claimType ?? L10n.Claim.Casetype.insuranceCase,
            productVariant: .init(data: claim.productVariant?.fragments.productVariantFragment),
            conversation: .init(fragment: claim.conversation.fragments.conversationFragment, type: .claim),
            appealInstructionsUrl: claim.appealInstructionsUrl,
            isUploadingFilesEnabled: claim.isUploadingFilesEnabled,
            showClaimClosedFlow: claim.showClaimClosedFlow,
            infoText: claim.infoText,
            displayItems: claim.displayItems.compactMap { item in
                let displayValue: String =
                    item.displayValue.localDateToDate?.displayDateDDMMMYYYYFormat ?? item.displayValue
                        .localDateToIso8601Date?
                        .displayDateDDMMMYYYYFormat ?? item.displayValue
                return .init(displayTitle: item.displayTitle, displayValue: displayValue)
            }
        )
    }
}

private extension GraphQLEnum<OctopusGraphQL.ClaimStatus> {
    var asClaimStatus: ClaimModel.ClaimStatus {
        switch self {
        case let .case(status):
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

private extension GraphQLEnum<OctopusGraphQL.ClaimOutcome> {
    var asClaimOutcome: ClaimModel.ClaimOutcome? {
        switch self {
        case let .case(status):
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

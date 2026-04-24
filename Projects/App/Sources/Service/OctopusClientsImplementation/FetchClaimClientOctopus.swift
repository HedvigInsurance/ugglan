import Claims
import Foundation
import hCore
import hGraphQL

class FetchClaimsClientOctopus: hFetchClaimsClient {
    @Inject var octopus: hOctopus

    func getActiveClaims() async throws -> [ClaimModel] {
        if Dependencies.featureFlags().isClaimHistoryEnabled {
            let activeClaimsData = try await octopus.client.fetch(
                query: OctopusGraphQL.ActiveClaimsQuery()
            )
            let activeClaims = activeClaimsData.currentMember.claimsActive.map {
                ClaimModel(claim: $0.fragments.claimFragment)
            }
            let partnerClaims = activeClaimsData.currentMember.partnerClaimsActive.map {
                ClaimModel(partnerClaim: $0.fragments.partnerClaimFragment)
            }
            return (activeClaims + partnerClaims)
                .sorted { lhs, rhs in
                    switch (lhs.submittedAt, rhs.submittedAt) {
                    case let (l?, r?): return l > r
                    case (_?, nil): return true
                    case (nil, _?): return false
                    case (nil, nil): return false
                    }
                }
        } else {
            let data = try await octopus.client.fetch(
                query: OctopusGraphQL.ClaimsQuery()
            )
            let claims = data.currentMember.claims.map { ClaimModel(claim: $0.fragments.claimFragment) }
            return claims
        }
    }

    func getHistoryClaims() async throws -> [ClaimModel] {
        let historyClaimsData = try await octopus.client.fetch(
            query: OctopusGraphQL.HistoryClaimsQuery()
        )
        let claimsHistory = historyClaimsData.currentMember.claimsHistory.map {
            ClaimModel(claim: $0.fragments.claimFragment)
        }
        let partnerClaimsHistory = historyClaimsData.currentMember.partnerClaimsHistory.map {
            ClaimModel(partnerClaim: $0.fragments.partnerClaimFragment)
        }
        return (claimsHistory + partnerClaimsHistory)
            .sorted { lhs, rhs in
                switch (lhs.submittedAt, rhs.submittedAt) {
                case let (l?, r?): return l > r
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): return false
                }
            }
    }
}

@MainActor
extension ClaimModel {
    public init(
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

@MainActor
extension ClaimModel {
    init(partnerClaim: OctopusGraphQL.PartnerClaimFragment) {
        self.init(
            id: partnerClaim.id,
            status: partnerClaim.status?.asClaimStatus ?? .none,
            outcome: nil,
            submittedAt: partnerClaim.submittedAt,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: MonetaryAmount(optionalFragment: partnerClaim.payoutAmount?.fragments.moneyFragment),
            targetFileUploadUri: "",
            claimType: partnerClaim.claimType ?? L10n.Claim.Casetype.insuranceCase,
            productVariant: .init(data: partnerClaim.productVariant?.fragments.productVariantFragment),
            conversation: nil,
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: false,
            showClaimClosedFlow: false,
            infoText: nil,
            displayItems: partnerClaim.displayItems.compactMap { item in
                let displayValue: String =
                    item.displayValue.localDateToDate?.displayDateDDMMMYYYYFormat ?? item.displayValue
                    .localDateToIso8601Date?
                    .displayDateDDMMMYYYYFormat ?? item.displayValue
                return .init(displayTitle: item.displayTitle, displayValue: displayValue)
            },
            isPartnerClaim: true
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.ClaimStatus> {
    fileprivate var asClaimStatus: ClaimModel.ClaimStatus {
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

extension GraphQLEnum<OctopusGraphQL.ClaimOutcome> {
    fileprivate var asClaimOutcome: ClaimModel.ClaimOutcome? {
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

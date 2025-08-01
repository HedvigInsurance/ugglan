import Campaign
import Foundation
import hCore
import hGraphQL
import PresentableStore

class hCampaignsClientOctopus: hCampaignClient {
    @Inject private var octopus: hOctopus

    func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        let query = OctopusGraphQL.DiscountsQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentDiscountsData(with: data, amountFromPaymentData: nil)
    }
}

@MainActor
extension PaymentDiscountsData {
    init(
        with data: OctopusGraphQL.DiscountsQuery.Data,
        amountFromPaymentData: MonetaryAmount?
    ) {
        let discounts: [Discount] = data.currentMember.redeemedCampaigns.filter { $0.type == .voucher }
            .compactMap { .init(with: $0, amountFromPaymentData: amountFromPaymentData) }
        self.init(
            discounts: discounts,
            referralsData: .init(with: data.currentMember.referralInformation)
        )
    }
}

@MainActor
extension Discount {
    init(
        with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.RedeemedCampaign,
        amountFromPaymentData: MonetaryAmount?

    ) {
        self.init(
            code: data.code,
            amount: amountFromPaymentData,
            title: data.description,
            listOfAffectedInsurances: data.onlyApplicableToContracts?
                .compactMap {
                    .init(
                        id: $0.id,
                        displayName: $0.getDisplayName
                    )
                } ?? [],
            validUntil: data.expiresAt,
            canBeDeleted: true,
            discountId: data.id
        )
    }

    public init(
        with moneyFragment: OctopusGraphQL.MoneyFragment,
        discountDto discount: ReedeemedCampaingDTO?
    ) {
        self.init(
            code: discount?.code ?? "",
            amount: .init(fragment: moneyFragment),
            title: discount?.description ?? "",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: false,
            discountId: UUID().uuidString
        )
    }
}

public extension OctopusGraphQL.MemberReferralInformationCodeFragment {
    func asReedeemedCampaing() -> ReedeemedCampaingDTO {
        .init(
            code: code,
            description: L10n.paymentsReferralDiscount
        )
    }
}

public struct ReedeemedCampaingDTO {
    let code: String
    let description: String
}

extension ReferralsData {
    init(with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.ReferralInformation) {
        var referrals: [Referral] = []
        if let invitedBy = data.referredBy?.fragments.memberReferralFragment2 {
            referrals.append(.init(with: invitedBy, invitedYou: true))
        }
        let amount = data.referrals.reduce(0) { partialResult, referal in
            if referal.status == .active {
                return partialResult + (referal.activeDiscount?.amount ?? 0)
            }
            return partialResult
        }
        let numberOfReferrals = data.referrals.filter { $0.status == .active }.count
        referrals.append(
            .init(
                id: UUID().uuidString,
                name: data.code,
                code: data.code,
                description: L10n.foreverReferralInvitedByYouPlural(numberOfReferrals),
                activeDiscount: MonetaryAmount(
                    amount: Float(amount),
                    currency: data.monthlyDiscountPerReferral.fragments.moneyFragment.currencyCode.rawValue
                ),
                status: .active
            )
        )
        self.init(
            code: data.code,
            discountPerMember: .init(fragment: data.monthlyDiscountPerReferral.fragments.moneyFragment),
            discount: .sek(10),
            referrals: referrals.reversed()
        )
    }
}

extension Referral {
    init(with data: OctopusGraphQL.MemberReferralFragment2, invitedYou: Bool = false) {
        self.init(
            id: UUID().uuidString,
            name: data.name,
            code: data.code,
            description: L10n.Forever.Referral.invitedYou(data.name),
            activeDiscount: .init(optionalFragment: data.activeDiscount?.fragments.moneyFragment),
            status: data.status.asReferralState,
            invitedYou: invitedYou
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.MemberReferralStatus> {
    var asReferralState: Referral.State {
        switch self {
        case let .case(t):
            switch t {
            case .pending:
                return .pending
            case .active:
                return .active
            case .terminated:
                return .terminated
            }
        case .unknown:
            return .unknown
        }
    }
}

private extension OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign.OnlyApplicableToContract {
    var getDisplayName: String {
        [
            currentAgreement.productVariant.displayNameShort ?? currentAgreement.productVariant.displayName,
            exposureDisplayNameShort,
        ]
        .displayName
    }
}

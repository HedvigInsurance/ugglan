import Foundation
import PresentableStore
import hCore
import hGraphQL

@MainActor
extension PaymentDiscountsData {
    init(
        with data: OctopusGraphQL.DiscountsQuery.Data,
        amountFromPaymentData: MonetaryAmount?
    ) {
        self.discounts = data.currentMember.redeemedCampaigns.filter({ $0.type == .voucher })
            .compactMap({ .init(with: $0, amountFromPaymentData: amountFromPaymentData) })
        self.referralsData = .init(with: data.currentMember.referralInformation)
    }
}

@MainActor
extension Discount {
    init(
        with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.RedeemedCampaign,
        amountFromPaymentData: MonetaryAmount?

    ) {
        self.id = UUID().uuidString
        self.amount = amountFromPaymentData
        self.canBeDeleted = true
        self.code = data.code
        self.discountId = data.id
        self.listOfAffectedInsurances =
            data.onlyApplicableToContracts?.compactMap({ .init(id: $0.id, displayName: $0.exposureDisplayNameShort) })
            ?? []
        self.title = data.description
        self.validUntil = data.expiresAt
    }

    public init(
        with moneyFragment: OctopusGraphQL.MoneyFragment,
        discountDto discount: ReedeemedCampaingDTO?
    ) {
        id = UUID().uuidString
        code = discount?.code ?? ""
        amount = .init(fragment: moneyFragment)
        title = discount?.description ?? ""
        listOfAffectedInsurances = []
        validUntil = nil
        canBeDeleted = false
        discountId = UUID().uuidString
    }

    public init(
        with data: OctopusGraphQL.MemberChargeBreakdownItemDiscountFragment,
        campaign: OctopusGraphQL.ReedemCampaignsFragment
    ) {
        self.id = UUID().uuidString
        self.amount = .init(fragment: data.discount.fragments.moneyFragment)
        self.code = data.code
        self.discountId = ""
        self.validUntil = nil
        self.title = campaign.redeemedCampaigns.first(where: { $0.code == data.code })?.description
        self.listOfAffectedInsurances = []
        self.canBeDeleted = true
    }
}

extension OctopusGraphQL.MemberReferralInformationCodeFragment {
    public func asReedeemedCampaing() -> ReedeemedCampaingDTO {
        return .init(
            code: code,
            description: L10n.paymentsReferralDiscount,
            type: GraphQLEnum<OctopusGraphQL.RedeemedCampaignType>(.referral),
            id: code
        )
    }
}

public struct ReedeemedCampaingDTO {
    let code: String
    let description: String
    let type: GraphQLEnum<OctopusGraphQL.RedeemedCampaignType>
    let id: String
}

extension ReferralsData {
    init(with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.ReferralInformation) {
        self.code = data.code
        self.discount = .sek(10)
        self.discountPerMember = .init(fragment: data.monthlyDiscountPerReferral.fragments.moneyFragment)
        var referrals: [Referral] = []
        if let invitedBy = data.referredBy?.fragments.memberReferralFragment2 {
            referrals.append(.init(with: invitedBy, invitedYou: true))
        }
        let code = data.code
        let amount = data.referrals.reduce(0) { partialResult, referal in
            if referal.status == .active {
                return partialResult + (referal.activeDiscount?.amount ?? 0)
            }
            return partialResult
        }
        let numberOfReferrals = data.referrals.filter({ $0.status == .active }).count
        referrals.append(
            .init(
                id: UUID().uuidString,
                name: code,
                code: nil,
                description: L10n.foreverReferralInvitedByYouPlural(numberOfReferrals),
                activeDiscount: MonetaryAmount(
                    amount: Float(amount),
                    currency: data.monthlyDiscountPerReferral.fragments.moneyFragment.currencyCode.rawValue
                ),
                status: .active
            )
        )
        self.referrals = referrals.filter({ $0.status == .active }).reversed()
    }
}

extension Referral {
    init(with data: OctopusGraphQL.MemberReferralFragment2, invitedYou: Bool = false) {
        self.id = UUID().uuidString
        self.status = data.status.asReferralState
        self.description = L10n.Forever.Referral.invitedYou(data.name)
        self.name = data.name
        self.code = data.code
        self.activeDiscount = .init(optionalFragment: data.activeDiscount?.fragments.moneyFragment)
        self.invitedYou = invitedYou
    }
}

extension GraphQLEnum<OctopusGraphQL.MemberReferralStatus> {
    var asReferralState: Referral.State {
        switch self {
        case .case(let t):
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

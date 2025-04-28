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
        self.grossAmount =
            .init(optionalFragment: data.currentMember.futureCharge?.gross.fragments.moneyFragment) ?? .sek(0)
        self.netAmount =
            .init(optionalFragment: data.currentMember.futureCharge?.net.fragments.moneyFragment) ?? .sek(0)
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
            data.onlyApplicableToContracts?.compactMap({ .init(id: $0.id, displayName: $0.exposureDisplayName) }) ?? []
        self.title = data.description
        self.validUntil = data.expiresAt
    }

    public init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discount: OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign?
    ) {
        self.id = UUID().uuidString
        code = data.code ?? discount?.code ?? ""
        amount = .init(fragment: data.discount.fragments.moneyFragment)
        title = discount?.description ?? ""
        listOfAffectedInsurances =
            discount?.onlyApplicableToContracts?
            .compactMap({
                .init(id: $0.id, displayName: $0.exposureDisplayName)
            }) ?? []
        validUntil = nil
        canBeDeleted = false
        discountId = UUID().uuidString
    }

    public init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discountDto discount: ReedeemedCampaingDTO?
    ) {
        id = UUID().uuidString
        code = data.code ?? discount?.code ?? ""
        amount = .init(fragment: data.discount.fragments.moneyFragment)
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
        referrals.append(contentsOf: data.referrals.compactMap({ .init(with: $0.fragments.memberReferralFragment2) }))
        self.referrals = referrals.reversed()
    }
}

extension Referral {
    init(with data: OctopusGraphQL.MemberReferralFragment2, invitedYou: Bool = false) {
        self.id = UUID().uuidString
        self.status = data.status.asReferralState
        self.name = data.name
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

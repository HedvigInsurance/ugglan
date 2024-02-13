import Foundation
import Presentation
import hGraphQL

extension PaymentDiscountsData {
    init(with data: OctopusGraphQL.DiscountsQuery.Data) {
        self.discounts = data.currentMember.redeemedCampaigns.filter({ $0.type == .voucher })
            .compactMap({ .init(with: $0) })
        self.referralsData = .init(with: data.currentMember.referralInformation)
    }
}

extension Discount {
    init(with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.RedeemedCampaign) {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        let amountFromPaymentData = store.state.paymentData?.discounts.first(where: { $0.code == data.code })?.amount
        self.amount = amountFromPaymentData
        self.canBeDeleted = true
        self.code = data.code
        self.id = data.id
        self.listOfAffectedInsurances =
            data.onlyApplicableToContracts?.compactMap({ .init(id: $0.id, displayName: $0.exposureDisplayName) }) ?? []
        self.title = data.description
        self.validUntil = data.expiresAt
    }
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
        case .unknown(let string):
            return .unknown
        }
    }
}

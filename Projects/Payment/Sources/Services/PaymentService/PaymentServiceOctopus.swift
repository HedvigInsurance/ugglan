import Foundation
import hCore
import hGraphQL

public class hPaymentServiceOctopus: hPaymentService {
    @Inject private var octopus: hOctopus

    public init() {}

    public func getPaymentData() async throws -> PaymentData {
        try await hPaymentServiceDemo().getPaymentData()
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        try await hPaymentServiceDemo().getPaymentStatusData()
    }

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        let query = OctopusGraphQL.DiscountsQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentDiscountsData.init(with: data)
    }

    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        return []
    }
}

extension PaymentDiscountsData {
    init(with data: OctopusGraphQL.DiscountsQuery.Data) {
        self.discounts = data.currentMember.redeemedCampaigns.filter({ $0.type == .voucher })
            .compactMap({ .init(with: $0) })
        self.referralsData = .init(with: data.currentMember.referralInformation)
    }
}

extension Discount {
    init(with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.RedeemedCampaign) {
        self.amount = nil
        self.canBeDeleted = true
        self.code = data.code
        self.id = data.id
        self.listOfAffectedInsurances = []
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
        if let invitedBy = data.referredBy?.fragments.memberReferralFragment {
            referrals.append(.init(with: invitedBy, invitedYou: true))
        }
        referrals.append(contentsOf: data.referrals.compactMap({ .init(with: $0.fragments.memberReferralFragment) }))
        self.referrals = referrals.reversed()
    }
}

extension Referral {
    init(with data: OctopusGraphQL.MemberReferralFragment, invitedYou: Bool = false) {
        self.id = UUID().uuidString
        self.status = data.status.asReferralState
        self.name = data.name
        self.activeDiscount = .init(optionalFragment: data.activeDiscount?.fragments.moneyFragment)
        self.invitedYou = invitedYou
    }
}

extension OctopusGraphQL.MemberReferralStatus {
    var asReferralState: Referral.State {
        switch self {
        case .pending:
            return .pending
        case .active:
            return .active
        case .terminated:
            return .terminated
        case .__unknown:
            return .unknown
        }
    }
}

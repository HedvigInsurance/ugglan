import Foundation
import hCore
import hGraphQL

public class hPaymentServiceOctopus: hPaymentService {
    @Inject private var octopus: hOctopus

    public init() {}

    public func getPaymentData() async throws -> PaymentData? {
        let query = OctopusGraphQL.PaymentDataQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentData(with: data)
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        let query = OctopusGraphQL.PaymentInformationQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentStatusData(data: data)
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

extension PaymentData {
    init?(with data: OctopusGraphQL.PaymentDataQuery.Data) {
        guard let futureCharge = data.currentMember.futureCharge else { return nil }
        let chargeFragment = futureCharge.fragments.memberChargeFragment
        payment = .init(with: chargeFragment)
        status = PaymentData.PaymentStatus.getStatus(with: futureCharge)
        contracts = chargeFragment.contractsChargeBreakdown.compactMap({ .init(with: $0) })
        let redeemedCampaigns = data.currentMember.fragments.reedemCampaignsFragment.redeemedCampaigns
        discounts = chargeFragment.discountBreakdown.compactMap({ discountBreakdown in
            .init(
                with: discountBreakdown,
                discount: redeemedCampaigns.first(where: { $0.code == discountBreakdown.code })
            )
        })
        paymentDetails = nil
        addedToThePayment = []
    }
}

extension PaymentData.PaymentStatus {
    static func getStatus(
        with data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.FutureCharge
    ) -> PaymentData.PaymentStatus {
        switch data.status {
        case .failed:
            if let includedInFutureCharge = data.includedInFutureCharge {
                return .addedtoFuture(
                    date: includedInFutureCharge.date,
                    withId: includedInFutureCharge.id,
                    isUpcoming: includedInFutureCharge.status == .upcoming
                )
            } else {
                return .failedForPrevious(
                    from: data.includingPreviousCharges.first?.date ?? "",
                    to: data.includingPreviousCharges.last?.date ?? ""
                )
            }
        case .pending:
            return .pending
        case .success:
            return .success
        case .upcoming:
            return .upcoming
        case .__unknown:
            return .unknown
        }
    }
}

extension PaymentData.PaymentStack {
    init(with data: OctopusGraphQL.MemberChargeFragment) {
        gross = .init(fragment: data.gross.fragments.moneyFragment)
        net = .init(fragment: data.net.fragments.moneyFragment)
        date = data.date
    }
}

extension PaymentData.ContractPaymentDetails {
    init(with data: OctopusGraphQL.MemberChargeFragment.ContractsChargeBreakdown) {
        id = UUID().uuidString
        title = data.contract.currentAgreement.productVariant.displayName
        subtitle = data.contract.exposureDisplayName
        amount = .init(fragment: data.gross.fragments.moneyFragment)
        periods = data.periods.compactMap({ .init(with: $0) })
    }
}

extension PaymentData.PeriodInfo {
    init(with data: OctopusGraphQL.MemberChargeFragment.ContractsChargeBreakdown.Period) {
        id = UUID().uuidString
        from = data.fromDate
        to = data.toDate
        amount = .init(fragment: data.amount.fragments.moneyFragment)
        isOutstanding = data.isPreviouslyFailedCharge
    }
}

extension Discount {
    init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discount: OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign?
    ) {
        id = UUID().uuidString
        code = data.code
        amount = .init(fragment: data.discount.fragments.moneyFragment)
        title = discount?.description ?? ""
        listOfAffectedInsurances = []
        validUntil = nil
        canBeDeleted = false
    }
}

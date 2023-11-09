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
        previousPaymentStatus = PaymentData.PaymentStatus.getValue(with: futureCharge)
        contracts = chargeFragment.contractsChargeBreakdown.compactMap({ .init(with: $0) })
        discounts = chargeFragment.discountBreakdown.compactMap({ .init(with: $0) })
        paymentDetails = nil
    }
}

extension PaymentData.PaymentStatus {
    static func getValue(
        with data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.FutureCharge
    ) -> PaymentData.PaymentStatus? {
        if let includedInFutureCharge = data.includedInFutureCharge {
            return .addedtoFuture(date: includedInFutureCharge.date, withId: includedInFutureCharge.id)
        }
        let includingPreviousCharges = data.includingPreviousCharges
        if includingPreviousCharges.count > 0 {
            return .failedForPrevious(
                from: includingPreviousCharges.first?.date ?? "",
                to: includingPreviousCharges.last?.date ?? ""
            )
        }
        return nil
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
        id = data.gross.amount.description
        title = data.contract.currentAgreement.productVariant.displayName
        subtitle = data.contract.exposureDisplayName
        amount = .init(fragment: data.gross.fragments.moneyFragment)
        periods = data.periods.compactMap({ .init(with: $0) })
    }
}

extension PaymentData.PeriodInfo {
    init(with data: OctopusGraphQL.MemberChargeFragment.ContractsChargeBreakdown.Period) {
        id = data.fromDate + data.toDate
        from = data.fromDate
        to = data.toDate
        amount = .init(fragment: data.amount.fragments.moneyFragment)
        isOutstanding = data.isPreviouslyFailedCharge
    }
}

extension Discount {
    init(with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown) {
        id = data.code
        code = data.code
        amount = .init(fragment: data.discount.fragments.moneyFragment)
        title = data.code
        listOfAffectedInsurances = []
        validUntil = nil
        canBeDeleted = false
    }
}

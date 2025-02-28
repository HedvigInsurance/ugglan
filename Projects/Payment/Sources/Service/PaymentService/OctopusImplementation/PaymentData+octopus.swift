import Foundation
import hCore
import hGraphQL

@MainActor
extension PaymentData {

    //used for upcoming payment
    init?(
        with data: OctopusGraphQL.PaymentDataQuery.Data,
        paymentDetails: PaymentDetails?
    ) {
        self.id = data.currentMember.futureCharge?.id ?? ""
        guard let futureCharge = data.currentMember.futureCharge else { return nil }
        let chargeFragment = futureCharge.fragments.memberChargeFragment
        payment = .init(with: chargeFragment)
        status = PaymentData.PaymentStatus.getStatus(for: chargeFragment, with: data.currentMember)
        contracts = chargeFragment.chargeBreakdown.compactMap({ .init(with: $0) })
        let redeemedCampaigns = data.currentMember.redeemedCampaigns
        discounts = chargeFragment.discountBreakdown.compactMap({ discountBreakdown in
            if discountBreakdown.isReferral {
                let dto = data.currentMember.referralInformation.fragments.memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return .init(with: discountBreakdown, discountDto: dto)
            } else {
                return .init(
                    with: discountBreakdown,
                    discount: redeemedCampaigns.first(where: { $0.code == discountBreakdown.code })
                )
            }
        })
        self.paymentDetails = paymentDetails
        addedToThePayment = []
    }

    // used for ongoing payments
    init(
        with data: OctopusGraphQL.MemberChargeFragment,
        paymentDataQueryCurrentMember: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember
    ) {
        self.id = data.id ?? ""
        payment = .init(with: data)
        status = PaymentData.PaymentStatus.getStatus(for: data, with: paymentDataQueryCurrentMember)
        contracts = data.chargeBreakdown.compactMap({ .init(with: $0) })
        let redeemedCampaigns = paymentDataQueryCurrentMember.redeemedCampaigns
        discounts = data.discountBreakdown.compactMap({ discountBreakdown in
            if let campaing = redeemedCampaigns.first(where: { $0.code == discountBreakdown.code }) {
                return .init(with: discountBreakdown, discount: campaing)
            } else {
                let dto = paymentDataQueryCurrentMember.referralInformation.fragments
                    .memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return .init(with: discountBreakdown, discountDto: dto)
            }
        })
        self.paymentDetails = nil
        addedToThePayment = []
    }
}

extension PaymentData.PaymentDetails {
    init?(with model: OctopusGraphQL.PaymentInformationQuery.Data) {
        guard let account = model.currentMember.paymentInformation.connection?.descriptor,
            let bank = model.currentMember.paymentInformation.connection?.displayName
        else { return nil }
        self.paymentMethod = L10n.paymentsAutogiroLabel
        self.account = account
        self.bank = bank
    }
}

@MainActor
extension PaymentData.PaymentStatus {
    static func getStatus(
        for charge: OctopusGraphQL.MemberChargeFragment,
        with data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember
    ) -> PaymentData.PaymentStatus {
        switch charge.status {
        case .case(let t):
            switch t {
            case .failed:
                return .upcoming
            case .pending:
                return .pending
            case .success:
                return .success
            case .upcoming:
                let previousChargesPeriods =
                    data.futureCharge?.chargeBreakdown.flatMap({ $0.periods })
                    .filter({ $0.isPreviouslyFailedCharge }) ?? []
                let from = previousChargesPeriods.compactMap({ $0.fromDate.localDateToDate }).min()
                let to = previousChargesPeriods.compactMap({ $0.toDate.localDateToDate }).max()
                if let from, let to {
                    return .failedForPrevious(from: from.localDateString, to: to.localDateString)
                }
                return .upcoming
            }
        case .unknown:
            return .unknown
        }
    }
}

@MainActor
extension PaymentData.PaymentStack {
    init(with data: OctopusGraphQL.MemberChargeFragment) {
        gross = .init(fragment: data.gross.fragments.moneyFragment)
        net = .init(fragment: data.net.fragments.moneyFragment)
        carriedAdjustment = .init(optionalFragment: data.carriedAdjustment?.fragments.moneyFragment)
        settlementAdjustment = .init(optionalFragment: data.settlementAdjustment?.fragments.moneyFragment)
        date = data.date
    }
}

@MainActor
extension PaymentData.ContractPaymentDetails {
    init(with data: OctopusGraphQL.MemberChargeFragment.ChargeBreakdown) {
        id = UUID().uuidString
        title = data.displayTitle
        subtitle = data.displaySubtitle
        amount = .init(fragment: data.gross.fragments.moneyFragment)
        periods = data.periods.compactMap({ .init(with: $0) })
    }
}

@MainActor
extension PaymentData.PeriodInfo {
    init(with data: OctopusGraphQL.MemberChargeFragment.ChargeBreakdown.Period) {
        id = UUID().uuidString
        from = data.fromDate
        to = data.toDate
        amount = .init(fragment: data.amount.fragments.moneyFragment)
        isOutstanding = data.isPreviouslyFailedCharge
        if isOutstanding {
            desciption = L10n.paymentsOutstandingPayment
        } else {
            desciption = data.getDescription
        }
    }
}

@MainActor
extension OctopusGraphQL.MemberChargeFragment.ChargeBreakdown.Period {
    fileprivate var getDescription: String? {
        guard let fromDate = fromDate.localDateToDate,
            let toDate = toDate.localDateToDate
        else {
            return nil
        }
        if fromDate.isFirstDayOfMonth && toDate.isLastDayOfMonth {
            return L10n.paymentsPeriodFull
        } else {
            let days = toDate.daysBetween(start: fromDate) + 1
            return L10n.paymentsPeriodDays(String(days))
        }
    }
}

extension Discount {
    init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discount: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.RedeemedCampaign?
    ) {
        id = UUID().uuidString
        code = data.code ?? discount?.code ?? ""
        amount = .init(fragment: data.discount.fragments.moneyFragment)
        title = discount?.description
        listOfAffectedInsurances =
            discount?.onlyApplicableToContracts?.compactMap({ .init(id: $0.id, displayName: $0.exposureDisplayName) })
            ?? []
        validUntil = nil
        canBeDeleted = false
    }

    init(
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
    }

}

extension OctopusGraphQL.MemberReferralInformationCodeFragment {
    func asReedeemedCampaing() -> ReedeemedCampaingDTO {
        return .init(
            code: code,
            description: L10n.paymentsReferralDiscount,
            type: GraphQLEnum<OctopusGraphQL.RedeemedCampaignType>(.referral),
            id: code
        )
    }
}

struct ReedeemedCampaingDTO {
    let code: String
    let description: String
    let type: GraphQLEnum<OctopusGraphQL.RedeemedCampaignType>
    let id: String
}

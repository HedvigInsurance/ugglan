import Campaign
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
        let referralDiscount: Discount? = {
            if let referalDiscount = chargeFragment.referralDiscount?.fragments.moneyFragment {
                let referralDescription = data.currentMember.referralInformation.fragments
                    .memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(with: referalDiscount, discountDto: referralDescription)
            }
            return nil
        }()

        self.referralDiscount = referralDiscount
        contracts = chargeFragment.chargeBreakdown.compactMap({
            .init(with: $0, campaign: data.currentMember.fragments.reedemCampaignsFragment)
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

        let referralDiscount: Discount? = {
            if let referalDiscount = data.referralDiscount?.fragments.moneyFragment {
                let referralDescription = paymentDataQueryCurrentMember.referralInformation.fragments
                    .memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(with: referalDiscount, discountDto: referralDescription)
            }
            return nil
        }()

        self.referralDiscount = referralDiscount
        contracts = data.chargeBreakdown.compactMap({
            .init(with: $0, campaign: paymentDataQueryCurrentMember.fragments.reedemCampaignsFragment)
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
    init(
        with data: OctopusGraphQL.MemberChargeFragment.ChargeBreakdown,
        campaign: OctopusGraphQL.ReedemCampaignsFragment
    ) {
        id = UUID().uuidString
        title = data.displayTitle
        subtitle = data.displaySubtitle
        grossAmount = .init(fragment: data.gross.fragments.moneyFragment)
        netAmount = .init(fragment: data.net.fragments.moneyFragment)
        discounts =
            data.discounts?
            .compactMap({ .init(with: $0.fragments.memberChargeBreakdownItemDiscountFragment, campaign: campaign) })
            ?? []
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

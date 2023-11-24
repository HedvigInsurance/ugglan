import Foundation
import hCore
import hGraphQL

extension PaymentData {
    init?(with data: OctopusGraphQL.PaymentDataQuery.Data) {
        self.id = data.currentMember.futureCharge?.id ?? ""
        guard let futureCharge = data.currentMember.futureCharge else { return nil }
        let chargeFragment = futureCharge.fragments.memberChargeFragment
        payment = .init(with: chargeFragment)
        status = PaymentData.PaymentStatus.getStatus(with: data.currentMember)
        contracts = chargeFragment.contractsChargeBreakdown.compactMap({ .init(with: $0) })
        let redeemedCampaigns = data.currentMember.redeemedCampaigns
        discounts = chargeFragment.discountBreakdown.compactMap({ discountBreakdown in
            .init(
                with: discountBreakdown,
                discount: redeemedCampaigns.first(where: { $0.code == discountBreakdown.code })
                    ?? data.currentMember.referralInformation.fragments.memberReferralInformationCodeFragment
                    .asReedeemedCampaingForPayment()
            )
        })
        paymentDetails = nil
        addedToThePayment = []
    }
}

extension PaymentData.PaymentStatus {
    static func getStatus(
        with data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember
    ) -> PaymentData.PaymentStatus {
        let charge = data.futureCharge
        switch charge?.status {
        case .failed:
            return .upcoming
        case .pending:
            return .pending
        case .success:
            return .success
        case .upcoming:
            let previousChargesPeriods =
                data.futureCharge?.contractsChargeBreakdown.flatMap({ $0.periods })
                .filter({ $0.isPreviouslyFailedCharge }) ?? []
            let from = previousChargesPeriods.compactMap({ $0.fromDate.localDateToDate }).min()
            let to = previousChargesPeriods.compactMap({ $0.toDate.localDateToDate }).max()
            if let from, let to {
                return .failedForPrevious(from: from.displayDateDDMMMFormat, to: to.displayDateDDMMMFormat)
            }
            return .upcoming
        case .__unknown:
            return .unknown
        case .none:
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
        if isOutstanding {
            desciption = L10n.paymentsOutstandingPayment
        } else {
            desciption = data.getDescription
        }
    }
}

extension OctopusGraphQL.MemberChargeFragment.ContractsChargeBreakdown.Period {
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
        title = discount?.description ?? ""
        listOfAffectedInsurances =
            discount?.onlyApplicableToContracts?.compactMap({ .init(id: $0.id, displayName: $0.exposureDisplayName) })
            ?? []
        validUntil = nil
        canBeDeleted = false
    }

}

extension OctopusGraphQL.MemberReferralInformationCodeFragment {
    func asReedeemedCampaing() -> OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign {
        let referralDescription = OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign(
            code: self.code,
            description: L10n.paymentsReferralDiscount,
            type: .referral,
            id: self.code
        )
        return referralDescription
    }

    func asReedeemedCampaingForPayment() -> OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.RedeemedCampaign {
        let referralDescription = OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.RedeemedCampaign(
            code: self.code,
            description: L10n.paymentsReferralDiscount,
            type: .referral,
            id: self.code
        )
        return referralDescription
    }
}

import Foundation
import hCore
import hGraphQL

extension PaymentData {
    init?(with data: OctopusGraphQL.PaymentDataQuery.Data) {
        guard let futureCharge = data.currentMember.futureCharge else { return nil }
        let chargeFragment = futureCharge.fragments.memberChargeFragment
        payment = .init(with: chargeFragment)
        status = PaymentData.PaymentStatus.getStatus(with: data.currentMember)
        contracts = chargeFragment.contractsChargeBreakdown.compactMap({ .init(with: $0) })
        let redeemedCampaigns = data.currentMember.fragments.reedemCampaignsFragment.redeemedCampaigns
        discounts = chargeFragment.discountBreakdown.compactMap({ discountBreakdown in
            .init(
                with: discountBreakdown,
                discount: redeemedCampaigns.first(where: { $0.code == discountBreakdown.code })
                    ?? data.currentMember.referralInformation.fragments.memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
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
            let previousChargesPeriods = data.pastCharges.map { pastCharge in
                pastCharge.contractsChargeBreakdown.flatMap({ $0.periods })
            }
            let from = previousChargesPeriods.flatMap({ $0 }).compactMap({ $0.fromDate.localDateToDate }).min()
            let to = previousChargesPeriods.flatMap({ $0 }).compactMap({ $0.toDate.localDateToDate }).max()
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
    }
}

extension Discount {
    init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discount: OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign?
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
    func asReedeemedCampaing() -> OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign {
        let referralDescription = OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign(
            code: self.code,
            description: L10n.paymentsReferralDiscount,
            type: .referral,
            id: self.code
        )
        return referralDescription
    }

}

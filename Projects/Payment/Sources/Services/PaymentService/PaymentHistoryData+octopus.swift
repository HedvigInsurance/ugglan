import Foundation
import Presentation
import hGraphQL

extension PaymentHistoryListData {
    static func getHistory(
        with data: OctopusGraphQL.PaymentHistoryDataQuery.Data.CurrentMember
    ) -> [PaymentHistoryListData] {
        var paymentHistoryList: [PaymentHistoryListData] = []
        let reedemCampaingsFragment = data.fragments.reedemCampaignsFragment
        var payments = [PaymentData]()
        var nextPayment: PaymentData?
        for item in data.pastCharges.enumerated() {
            if item.offset == data.pastCharges.count {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                nextPayment = store.state.paymentData
            }
            let paymentData = PaymentData(
                with: item.element.fragments.memberChargeFragment,
                campaings: reedemCampaingsFragment,
                referralInfo: data.referralInformation,
                nextPayment: nextPayment
            )
            nextPayment = paymentData
            payments.append(paymentData)
        }
        let charges = payments.compactMap({ PaymentHistory(id: $0.payment.date, paymentData: $0) })
        let groupedPaymenthsByYear = Dictionary(grouping: charges, by: { $0.paymentData.payment.date.year ?? 0 })

        for year in groupedPaymenthsByYear.keys.sorted(by: { $0 > $1 }) {
            let history = groupedPaymenthsByYear[year] ?? []
            let paymentHistoryForYear = PaymentHistoryListData(
                id: String(year),
                year: String(year),
                valuesPerMonth: history
            )
            paymentHistoryList.append(paymentHistoryForYear)
        }
        return paymentHistoryList
    }
}

extension PaymentData {
    init(
        with data: OctopusGraphQL.MemberChargeFragment,
        campaings: OctopusGraphQL.ReedemCampaignsFragment,
        referralInfo: OctopusGraphQL.PaymentHistoryDataQuery.Data.CurrentMember.ReferralInformation,
        nextPayment: PaymentData? = nil
    ) {
        self.id = data.id ?? ""
        let chargeFragment = data
        payment = .init(with: chargeFragment)
        status = PaymentData.PaymentStatus.getStatus(with: chargeFragment, and: nextPayment)
        contracts = chargeFragment.contractsChargeBreakdown.compactMap({ .init(with: $0) })
        let redeemedCampaigns = campaings.redeemedCampaigns
        discounts = chargeFragment.discountBreakdown.compactMap({ discountBreakdown in
            if discountBreakdown.isReferral {
                let referralDescription = referralInfo.fragments.memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(
                    with: discountBreakdown,
                    discountDto: referralDescription
                )
            } else {
                return Discount.init(
                    with: discountBreakdown,
                    discount: redeemedCampaigns.first(where: { $0.code == discountBreakdown.code })
                )
            }
        })

        paymentDetails = nil
        if let nextPayment {
            addedToThePayment = [nextPayment]
        } else {
            addedToThePayment = []
        }
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

extension PaymentData.PaymentStatus {
    static func getStatus(
        with data: OctopusGraphQL.MemberChargeFragment,
        and nextPayment: PaymentData?
    ) -> PaymentData.PaymentStatus {
        switch data.status {
        case let .case(status):
            switch status {
            case .failed:
                return .addedtoFuture(
                    date: nextPayment?.payment.date ?? ""
                )
            case .pending:
                return .pending
            case .success:
                return .success
            case .upcoming:
                return .upcoming
            }
        case .unknown(_):
            return .unknown
        }
    }
}

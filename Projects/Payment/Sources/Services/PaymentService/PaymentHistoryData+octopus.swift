import Foundation
import hGraphQL

extension PaymentHistoryListData {
    static func getHistory(
        with data: OctopusGraphQL.PaymentHistoryDataQuery.Data.CurrentMember
    ) -> [PaymentHistoryListData] {
        var paymentHistoryList: [PaymentHistoryListData] = []
        let reedemCampaingsFragment = data.fragments.reedemCampaignsFragment
        let charges = data.pastCharges
            .compactMap({ $0.fragments.memberChargeFragment })
            .compactMap({ PaymentData(with: $0, campaings: reedemCampaingsFragment) })
            .compactMap({ PaymentHistory(id: $0.payment.date, paymentData: $0) })
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
    init?(
        with data: OctopusGraphQL.MemberChargeFragment,
        campaings: OctopusGraphQL.ReedemCampaignsFragment
    ) {
        let chargeFragment = data
        payment = .init(with: chargeFragment)
        status = PaymentData.PaymentStatus.getStatus(with: chargeFragment, and: nil)
        contracts = chargeFragment.contractsChargeBreakdown.compactMap({ .init(with: $0) })
        let redeemedCampaigns = campaings.redeemedCampaigns
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
        with data: OctopusGraphQL.MemberChargeFragment,
        and next: OctopusGraphQL.MemberChargeFragment?
    ) -> PaymentData.PaymentStatus {
        switch data.status {
        case .failed:
            return .addedtoFuture(date: next?.date ?? "", withId: next?.id ?? "", isUpcoming: next?.status == .upcoming)
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

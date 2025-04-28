import Campaign
import Foundation
import PresentableStore
import hGraphQL

@MainActor
extension PaymentHistoryListData {
    static func getHistory(
        with data: OctopusGraphQL.PaymentHistoryDataQuery.Data.CurrentMember
    ) -> [PaymentHistoryListData] {
        var paymentHistoryList: [PaymentHistoryListData] = []
        let reedemCampaingsFragment = data.fragments.reedemCampaignsFragment
        var payments = [PaymentData]()
        var nextPayment: PaymentData?
        for item in data.pastCharges.enumerated() {
            if item.offset == 0 {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                nextPayment = store.state.ongoingPaymentData.first ?? store.state.paymentData
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

@MainActor
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
        let redeemedCampaigns = campaings.redeemedCampaigns

        let referralDiscounts = chargeFragment.discountBreakdown.filter({ $0.isReferral })
            .compactMap({
                let referralDescription = referralInfo.fragments.memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(
                    with: $0,
                    discountDto: referralDescription
                )
            })

        let otherDiscounts = chargeFragment.discountBreakdown.filter({ !$0.isReferral })
            .compactMap({
                Discount.init(
                    with: $0,
                    discount: redeemedCampaigns.first(where: { $0.code == $0.code })
                )
            })

        self.referralDiscounts = referralDiscounts
        self.otherDiscounts = otherDiscounts
        contracts = chargeFragment.chargeBreakdown.compactMap({
            .init(with: $0, campaign: campaings)
        })
        paymentDetails = nil
        if let nextPayment {
            addedToThePayment = [nextPayment]
        } else {
            addedToThePayment = []
        }
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

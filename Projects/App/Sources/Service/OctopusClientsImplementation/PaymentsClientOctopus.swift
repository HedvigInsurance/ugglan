import Campaign
import Foundation
import Payment
import PresentableStore
import hCore
import hGraphQL

extension GraphQLEnum<OctopusGraphQL.MemberPaymentConnectionStatus> {
    var asPayinMethodStatus: PayinMethodStatus {
        switch self {
        case .case(let t):
            switch t {
            case .active:
                return .active
            case .pending:
                return .pending
            case .needsSetup:
                return .needsSetup
            }
        case .unknown:
            return .unknown
        }
    }
}

@MainActor
extension PaymentStatusData {
    init(data: OctopusGraphQL.PaymentInformationQuery.Data) {
        let status: PayinMethodStatus = {
            if data.currentMember.activeContracts.isEmpty && data.currentMember.pendingContracts.isEmpty {
                return .noNeedToConnect
            }

            let missedPaymentsContracts = data.currentMember.activeContracts.filter({
                $0.terminationDueToMissedPayments
            })
            if !missedPaymentsContracts.isEmpty {
                if let date = missedPaymentsContracts.compactMap({ $0.terminationDate?.localDateToDate }).sorted()
                    .first?
                    .displayDateDDMMMYYYYFormat
                {
                    return .contactUs(date: date)
                }
            }

            return data.currentMember.paymentInformation.status.asPayinMethodStatus
        }()
        self.init(
            status: status,
            displayName: data.currentMember.paymentInformation.connection?.displayName,
            descriptor: data.currentMember.paymentInformation.connection?.descriptor
        )
    }
}

public class hPaymentClientOctopus: hPaymentClient {
    @Inject private var octopus: hOctopus

    public init() {}

    public func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData]) {
        let query = OctopusGraphQL.PaymentDataQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

        let paymentDetailsQuery = OctopusGraphQL.PaymentInformationQuery()
        let paymentDetailsData = try await octopus.client.fetch(
            query: paymentDetailsQuery,
            cachePolicy: .fetchIgnoringCacheCompletely
        )

        let paymentDetails = PaymentData.PaymentDetails(with: paymentDetailsData)
        let upcomingPayment = PaymentData(with: data, paymentDetails: paymentDetails)
        let ongoingPayments: [PaymentData] = data.currentMember.ongoingCharges.compactMap({
            .init(with: $0.fragments.memberChargeFragment, paymentDataQueryCurrentMember: data.currentMember)
        })
        return (upcomingPayment, ongoingPayments)

    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        let query = OctopusGraphQL.PaymentInformationQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentStatusData(data: data)
    }

    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        let query = OctopusGraphQL.PaymentHistoryDataQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentHistoryListData.getHistory(with: data.currentMember)
    }

    public func getConnectPaymentUrl() async throws -> URL {
        let mutation = OctopusGraphQL.RegisterDirectDebitMutation(clientContext: GraphQLNullable.none)
        let data = try await octopus.client.perform(mutation: mutation)
        if let url = URL(string: data.registerDirectDebit2.url) {
            return url
        }
        throw PaymentError.missingDataError(message: L10n.General.errorBody)
    }
}

@MainActor
extension PaymentData {
    //used for upcoming payment
    init?(
        with data: OctopusGraphQL.PaymentDataQuery.Data,
        paymentDetails: PaymentDetails?
    ) {

        guard let futureCharge = data.currentMember.futureCharge else { return nil }
        let chargeFragment = futureCharge.fragments.memberChargeFragment
        let referralDiscount: Discount? = {
            if let referalDiscount = chargeFragment.referralDiscount?.fragments.moneyFragment {
                let referralDescription = data.currentMember.referralInformation.fragments
                    .memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(with: referalDiscount, discountDto: referralDescription)
            }
            return nil
        }()
        self.init(
            id: data.currentMember.futureCharge?.id ?? "",
            payment: .init(with: chargeFragment),
            status: PaymentData.PaymentStatus.getStatus(for: chargeFragment, with: data.currentMember),
            contracts: chargeFragment.chargeBreakdown.compactMap({
                .init(with: $0)
            }),
            referralDiscount: referralDiscount,
            paymentDetails: paymentDetails,
            addedToThePayment: []
        )
    }

    // used for ongoing payments
    init(
        with data: OctopusGraphQL.MemberChargeFragment,
        paymentDataQueryCurrentMember: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember
    ) {

        let referralDiscount: Discount? = {
            if let referalDiscount = data.referralDiscount?.fragments.moneyFragment {
                let referralDescription = paymentDataQueryCurrentMember.referralInformation.fragments
                    .memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(with: referalDiscount, discountDto: referralDescription)
            }
            return nil
        }()
        self.init(
            id: data.id ?? "",
            payment: .init(with: data),
            status: PaymentData.PaymentStatus.getStatus(for: data, with: paymentDataQueryCurrentMember),
            contracts: data.chargeBreakdown.compactMap({
                .init(with: $0)
            }),
            referralDiscount: referralDiscount,
            paymentDetails: nil,
            addedToThePayment: []
        )
    }
}

extension PaymentData.PaymentDetails {
    init?(with model: OctopusGraphQL.PaymentInformationQuery.Data) {
        guard let account = model.currentMember.paymentInformation.connection?.descriptor,
            let bank = model.currentMember.paymentInformation.connection?.displayName
        else { return nil }
        self.init(
            paymentMethod: L10n.paymentsAutogiroLabel,
            account: account,
            bank: bank
        )
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
        self.init(
            gross: .init(fragment: data.gross.fragments.moneyFragment),
            net: .init(fragment: data.net.fragments.moneyFragment),
            carriedAdjustment: .init(optionalFragment: data.carriedAdjustment?.fragments.moneyFragment),
            settlementAdjustment: .init(optionalFragment: data.settlementAdjustment?.fragments.moneyFragment),
            date: data.date
        )
    }
}

@MainActor
extension PaymentData.ContractPaymentDetails {
    init(
        with data: OctopusGraphQL.MemberChargeFragment.ChargeBreakdown
    ) {
        self.init(
            id: UUID().uuidString,
            title: data.displayTitle,
            subtitle: data.displaySubtitle,
            netAmount: .init(fragment: data.net.fragments.moneyFragment),
            grossAmount: .init(fragment: data.gross.fragments.moneyFragment),
            discounts: data.discounts?
                .compactMap({ .init(with: $0.fragments.memberChargeBreakdownItemDiscountFragment) })
                ?? [],
            periods: data.periods.compactMap({ .init(with: $0) })
        )
    }
}

@MainActor
extension PaymentData.PeriodInfo {
    init(with data: OctopusGraphQL.MemberChargeFragment.ChargeBreakdown.Period) {
        let isOutstanding = data.isPreviouslyFailedCharge
        self.init(
            id: UUID().uuidString,
            from: data.fromDate,
            to: data.toDate,
            amount: .init(fragment: data.amount.fragments.moneyFragment),
            isOutstanding: isOutstanding,
            desciption: {
                if isOutstanding {
                    return L10n.paymentsOutstandingPayment
                } else {
                    return data.getDescription
                }
            }()
        )
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

@MainActor
extension PaymentHistoryListData {
    static func getHistory(
        with data: OctopusGraphQL.PaymentHistoryDataQuery.Data.CurrentMember
    ) -> [PaymentHistoryListData] {
        var paymentHistoryList: [PaymentHistoryListData] = []
        var payments = [PaymentData]()
        var nextPayment: PaymentData?
        for item in data.pastCharges.enumerated() {
            if item.offset == 0 {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                nextPayment = store.state.ongoingPaymentData.first ?? store.state.paymentData
            }
            let paymentData = PaymentData(
                with: item.element.fragments.memberChargeFragment,
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
        referralInfo: OctopusGraphQL.PaymentHistoryDataQuery.Data.CurrentMember.ReferralInformation,
        nextPayment: PaymentData? = nil
    ) {
        let chargeFragment = data
        let referralDiscount: Discount? = {
            if let referalDiscount = chargeFragment.referralDiscount?.fragments.moneyFragment {
                let referralDescription = referralInfo.fragments.memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(with: referalDiscount, discountDto: referralDescription)
            }
            return nil
        }()
        self.init(
            id: data.id ?? "",
            payment: .init(with: chargeFragment),
            status: PaymentData.PaymentStatus.getStatus(with: chargeFragment, and: nextPayment),
            contracts: chargeFragment.chargeBreakdown.compactMap({ .init(with: $0) }),
            referralDiscount: referralDiscount,
            paymentDetails: nil,
            addedToThePayment: {
                if let nextPayment {
                    [nextPayment]
                } else {
                    []
                }
            }()
        )
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

@MainActor
extension Discount {
    public init(
        with data: OctopusGraphQL.MemberChargeBreakdownItemDiscountFragment
    ) {
        self.init(
            code: data.code,
            amount: .init(fragment: data.discount.fragments.moneyFragment),
            title: data.description,
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: true,
            discountId: ""
        )
    }
}

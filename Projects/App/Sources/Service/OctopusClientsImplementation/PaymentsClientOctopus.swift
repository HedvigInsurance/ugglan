import Campaign
import Foundation
import Payment
import PresentableStore
import hCore
import hGraphQL

extension GraphQLEnum<OctopusGraphQL.MemberPaymentMethodStatus> {
    var asPayinMethodStatus: PayinMethodStatus {
        switch self {
        case let .case(t):
            switch t {
            case .active:
                return .active
            case .pending:
                return .pending
            }
        case .unknown:
            return .unknown
        }
    }
}

@MainActor
extension PaymentStatusData {
    init(data: OctopusGraphQL.PaymentMethodsQuery.Data) {
        let status: PayinMethodStatus = {
            if data.currentMember.activeContracts.isEmpty, data.currentMember.pendingContracts.isEmpty {
                return .noNeedToConnect
            }

            let missedPaymentsContracts = data.currentMember.activeContracts.filter(\.terminationDueToMissedPayments)
            if !missedPaymentsContracts.isEmpty {
                if let date = missedPaymentsContracts.compactMap({ $0.terminationDate?.localDateToDate }).sorted()
                    .first?
                    .displayDateDDMMMYYYYFormat
                {
                    return .contactUs(date: date)
                }
            }

            guard
                let defaultPayin = data.currentMember.paymentMethods.defaultPayinMethod?.fragments
                    .memberPaymentMethodFragment
                    ?? data.currentMember.paymentMethods.payinMethods.first?.fragments.memberPaymentMethodFragment
            else {
                return .needsSetup
            }
            return defaultPayin.status.asPayinMethodStatus
        }()
        let paymentMethods = data.currentMember.paymentMethods

        let payinMethods: [PaymentMethodData] = paymentMethods.payinMethods.map {
            PaymentMethodData(fragment: $0.fragments.memberPaymentMethodFragment)
        }

        let payoutMethods: [PaymentMethodData] = paymentMethods.payoutMethods.map {
            PaymentMethodData(fragment: $0.fragments.memberPaymentMethodFragment)
        }

        let availableMethods: [AvailablePaymentMethod] = paymentMethods.availableMethods.map {
            .init(
                provider: PaymentProvider.from(graphQL: $0.provider),
                supportsPayin: $0.supportsPayin,
                supportsPayout: $0.supportsPayout
            )
        }

        let defaultPayinMethod: PaymentMethodData? = paymentMethods.defaultPayinMethod
            .map { PaymentMethodData(fragment: $0.fragments.memberPaymentMethodFragment) }

        let defaultPayoutMethod: PaymentMethodData? = paymentMethods.defaultPayoutMethod
            .map { PaymentMethodData(fragment: $0.fragments.memberPaymentMethodFragment) }

        self.init(
            status: status,
            chargingDay: paymentMethods.chargingDay,
            defaultPayinMethod: defaultPayinMethod,
            payinMethods: payinMethods,
            defaultPayoutMethod: defaultPayoutMethod,
            payoutMethods: payoutMethods,
            availableMethods: availableMethods
        )
    }
}

extension PaymentProvider {
    static func from(graphQL provider: GraphQLEnum<OctopusGraphQL.MemberPaymentProvider>) -> PaymentProvider {
        switch provider {
        case .case(.trustly): return .trustly
        case .case(.swish): return .swish
        case .case(.nordea): return .nordea
        case .case(.invoice): return .invoice
        default: return .unknown
        }
    }
}

@MainActor
extension PaymentMethodData {
    init(fragment: OctopusGraphQL.MemberPaymentMethodFragment) {
        let provider = PaymentProvider.from(graphQL: fragment.provider)
        let status: PaymentMethodStatus = {
            switch fragment.status {
            case .case(.active): return .active
            case .case(.pending): return .pending
            default: return .unknown
            }
        }()
        let details: PaymentMethodDetails? = {
            if let bankAccount = fragment.details?.asPaymentMethodBankAccountDetails {
                return .bankAccount(account: bankAccount.account, bank: bankAccount.bank)
            } else if let swish = fragment.details?.asPaymentMethodSwishDetails {
                return .swish(phoneNumber: swish.phoneNumber)
            } else if let invoice = fragment.details?.asPaymentMethodInvoiceDetails {
                let delivery: PaymentMethodDetails.InvoiceDelivery = {
                    switch invoice.delivery {
                    case .case(.kivra): return .kivra
                    case .case(.mail): return .mail
                    default: return .unknown
                    }
                }()
                return .invoice(delivery: delivery, email: invoice.email)
            }
            return nil
        }()
        self.init(
            provider: provider,
            status: status,
            isDefault: fragment.isDefault,
            details: details
        )
    }
}

class hPaymentClientOctopus: hPaymentClient {
    @Inject private var octopus: hOctopus

    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData]) {
        // Capture client on MainActor to avoid crossing actor boundary with non-Sendable `hOctopus`
        let client = octopus.client

        async let dataResult = client.fetch(query: OctopusGraphQL.PaymentDataQuery())
        async let paymentDetailsResult = client.fetch(query: OctopusGraphQL.PaymentMethodsQuery())

        let (data, paymentDetailsData) = try await (dataResult, paymentDetailsResult)

        let amountPerReferral = MonetaryAmount(
            fragment: data.currentMember.referralInformation.monthlyDiscountPerReferral.fragments
                .moneyFragment
        )
        let upcomingPayment = PaymentData(
            with: data,
            paymentMethodsData: paymentDetailsData,
            amountPerReferral: amountPerReferral
        )
        let ongoingPayments: [PaymentData] = data.currentMember.ongoingCharges.compactMap {
            .init(
                with: $0.fragments.memberChargeFragment,
                paymentDataQueryCurrentMember: data.currentMember,
                amountPerReferral: amountPerReferral
            )
        }
        return (upcomingPayment, ongoingPayments)
    }

    func getPaymentStatusData() async throws -> PaymentStatusData {
        let query = OctopusGraphQL.PaymentMethodsQuery()
        let data = try await octopus.client.fetch(query: query)
        return PaymentStatusData(data: data)
    }

    func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        let query = OctopusGraphQL.PaymentHistoryDataQuery()
        let data = try await octopus.client.fetch(query: query)
        return PaymentHistoryListData.getHistory(with: data.currentMember)
    }

    func setupPaymentMethod(_ type: PaymentMethodSetupType) async throws -> PaymentSetupResult {
        switch type {
        case .trustly:
            let input = OctopusGraphQL.PaymentMethodSetupTrustlyInput(
                successUrl: "hedvig://payment/success",
                failureUrl: "hedvig://payment/failure"
            )
            let mutation = OctopusGraphQL.PaymentMethodSetupTrustlyMutation(input: input)
            let data = try await octopus.client.mutation(mutation: mutation)!
            return data.paymentMethodSetupTrustly.fragments.paymentMethodSetupOutputFragment.toPaymentSetupResult()
        case let .nordeaPayout(clearingNumber, accountNumber):
            let input = OctopusGraphQL.PaymentMethodSetupNordeaPayoutInput(
                clearingNumber: clearingNumber,
                accountNumber: accountNumber
            )
            let mutation = OctopusGraphQL.PaymentMethodSetupNordeaPayoutMutation(input: input)
            let data = try await octopus.client.mutation(mutation: mutation)!
            return data.paymentMethodSetupNordeaPayout.fragments.paymentMethodSetupOutputFragment.toPaymentSetupResult()
        }
    }
}

extension OctopusGraphQL.PaymentMethodSetupOutputFragment {
    func toPaymentSetupResult() -> PaymentSetupResult {
        let status: PaymentSetupResult.PaymentSetupStatus = {
            switch self.status {
            case .case(.active): return .active
            case .case(.pending): return .pending
            case .case(.failed): return .failed
            default: return .unknown
            }
        }()
        return PaymentSetupResult(status: status, url: url, errorMessage: error?.message)
    }
}

@MainActor
extension PaymentData {
    // used for upcoming payment
    init?(
        with data: OctopusGraphQL.PaymentDataQuery.Data,
        paymentMethodsData: OctopusGraphQL.PaymentMethodsQuery.Data,
        amountPerReferral: MonetaryAmount
    ) {
        guard let futureCharge = data.currentMember.futureCharge else { return nil }
        let chargeFragment = futureCharge.fragments.memberChargeFragment
        let referralDiscount: Discount? = {
            if let referalDiscount = chargeFragment.referralDiscount?.fragments.moneyFragment {
                let referralDescription = data.currentMember.referralInformation.fragments
                    .memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount.init(
                    with: referalDiscount,
                    discountDto: referralDescription
                )
            }
            return nil
        }()

        let payinMethod: PaymentMethodData? = paymentMethodsData.currentMember.paymentMethods.defaultPayinMethod
            .map { PaymentMethodData(fragment: $0.fragments.memberPaymentMethodFragment) }

        self.init(
            id: data.currentMember.futureCharge?.id ?? "",
            payment: .init(with: chargeFragment),
            status: PaymentData.PaymentStatus.getStatus(for: chargeFragment, with: data.currentMember),
            contracts: chargeFragment.chargeBreakdown.compactMap {
                .init(with: $0)
            },
            referralDiscount: referralDiscount,
            amountPerReferral: amountPerReferral,
            payinMethod: payinMethod,
            addedToThePayment: []
        )
    }

    // used for ongoing payments
    init(
        with data: OctopusGraphQL.MemberChargeFragment,
        paymentDataQueryCurrentMember: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember,
        amountPerReferral: MonetaryAmount
    ) {
        let referralDiscount: Discount? = {
            if let referalDiscount = data.referralDiscount?.fragments.moneyFragment {
                let referralDescription = paymentDataQueryCurrentMember.referralInformation.fragments
                    .memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount(with: referalDiscount, discountDto: referralDescription)
            }
            return nil
        }()
        let payingMethod: PaymentMethodData? = {
            if let paymentProvider = data.paymentProvider {
                let realPaymentProvider = PaymentProvider.from(providerString: paymentProvider)
                return PaymentMethodData.init(
                    provider: realPaymentProvider,
                    status: .active,
                    isDefault: true,
                    details: nil
                )
            }
            return nil
        }()
        self.init(
            id: data.id ?? "",
            payment: .init(with: data),
            status: PaymentData.PaymentStatus.getStatus(for: data, with: paymentDataQueryCurrentMember),
            contracts: data.chargeBreakdown.compactMap {
                .init(with: $0)
            },
            referralDiscount: referralDiscount,
            amountPerReferral: amountPerReferral,
            payinMethod: payingMethod,
            addedToThePayment: []
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
        case let .case(t):
            switch t {
            case .failed:
                return .upcoming
            case .pending:
                return .pending
            case .success:
                return .success
            case .upcoming:
                let previousChargesPeriods =
                    data.futureCharge?.chargeBreakdown.flatMap(\.periods)
                    .filter(\.isPreviouslyFailedCharge) ?? []
                let from = previousChargesPeriods.compactMap(\.fromDate.localDateToDate).min()
                let to = previousChargesPeriods.compactMap(\.toDate.localDateToDate).max()
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
            periods: data.periods.compactMap { .init(with: $0) },
            priceBreakdown:
                data.insurancePriceBreakdown.map {
                    .init(
                        displayTitle: $0.displayTitle,
                        amount: MonetaryAmount(fragment: $0.amount.fragments.moneyFragment)
                    )
                }
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
        if fromDate.isFirstDayOfMonth, toDate.isLastDayOfMonth {
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
        let charges = payments.compactMap { PaymentHistory(id: $0.payment.date, paymentData: $0) }
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
        let amountPerReferral = MonetaryAmount(
            fragment: referralInfo.monthlyDiscountPerReferral.fragments.moneyFragment
        )
        let chargeFragment = data
        let referralDiscount: Discount? = {
            if let referalDiscount = chargeFragment.referralDiscount?.fragments.moneyFragment {
                let referralDescription = referralInfo.fragments.memberReferralInformationCodeFragment
                    .asReedeemedCampaing()
                return Discount(with: referalDiscount, discountDto: referralDescription)
            }
            return nil
        }()

        let payingMethod: PaymentMethodData? = {
            if let paymentProvider = data.paymentProvider {
                let realPaymentProvider = PaymentProvider.from(providerString: paymentProvider)
                return PaymentMethodData.init(
                    provider: realPaymentProvider,
                    status: .active,
                    isDefault: true,
                    details: nil
                )
            }
            return nil
        }()
        self.init(
            id: data.id ?? "",
            payment: .init(with: chargeFragment),
            status: PaymentData.PaymentStatus.getStatus(with: chargeFragment, and: nextPayment),
            contracts: chargeFragment.chargeBreakdown.compactMap {
                .init(with: $0)
            },
            referralDiscount: referralDiscount,
            amountPerReferral: amountPerReferral,
            payinMethod: payingMethod,
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
        case .unknown:
            return .unknown
        }
    }
}

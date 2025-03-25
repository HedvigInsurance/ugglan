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

public class hCampaingsClientOctopus: hCampaignClient {
    @Inject private var octopus: hOctopus
    public init() {}

    public func remove(codeId: String) async throws {
        let data = try await octopus.client.perform(
            mutation: OctopusGraphQL.MemberCampaignsUnredeemMutation(memberCampaignsUnredeemId: codeId)
        )
        if let errorMessage = data.memberCampaignsUnredeem.userError?.message {
            throw CampaignError.userError(message: errorMessage)
        }
    }

    public func add(code: String) async throws {
        let data = try await octopus.client.perform(mutation: OctopusGraphQL.RedeemCodeMutation(code: code))
        if let errorMessage = data.memberCampaignsRedeem.userError?.message {
            throw CampaignError.userError(message: errorMessage)
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

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        let query = OctopusGraphQL.DiscountsQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return PaymentDiscountsData.init(with: data)
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
        let redeemedCampaigns = data.currentMember.redeemedCampaigns
        self.init(
            id: data.currentMember.futureCharge?.id ?? "",
            payment: .init(with: chargeFragment),
            status: PaymentData.PaymentStatus.getStatus(for: chargeFragment, with: data.currentMember),
            contracts: chargeFragment.chargeBreakdown.compactMap({ .init(with: $0) }),
            discounts: chargeFragment.discountBreakdown.compactMap({ discountBreakdown in
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
            }),
            paymentDetails: paymentDetails,
            addedToThePayment: []
        )
    }

    // used for ongoing payments
    init(
        with data: OctopusGraphQL.MemberChargeFragment,
        paymentDataQueryCurrentMember: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember
    ) {
        let redeemedCampaigns = paymentDataQueryCurrentMember.redeemedCampaigns
        self.init(
            id: data.id ?? "",
            payment: .init(with: data),
            status: PaymentData.PaymentStatus.getStatus(for: data, with: paymentDataQueryCurrentMember),
            contracts: data.chargeBreakdown.compactMap({ .init(with: $0) }),
            discounts: data.discountBreakdown.compactMap({ discountBreakdown in
                if let campaing = redeemedCampaigns.first(where: { $0.code == discountBreakdown.code }) {
                    return .init(with: discountBreakdown, discount: campaing)
                } else {
                    let dto = paymentDataQueryCurrentMember.referralInformation.fragments
                        .memberReferralInformationCodeFragment
                        .asReedeemedCampaing()
                    return .init(with: discountBreakdown, discountDto: dto)
                }
            }),
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
    init(with data: OctopusGraphQL.MemberChargeFragment.ChargeBreakdown) {
        self.init(
            id: UUID().uuidString,
            title: data.displayTitle,
            subtitle: data.displaySubtitle,
            amount: .init(fragment: data.gross.fragments.moneyFragment),
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

extension Discount {
    init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discount: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.RedeemedCampaign?
    ) {
        self.init(
            id: UUID().uuidString,
            code: data.code ?? discount?.code ?? "",
            amount: .init(fragment: data.discount.fragments.moneyFragment),
            title: discount?.description,
            listOfAffectedInsurances:
                discount?.onlyApplicableToContracts?
                .compactMap({ .init(id: $0.id, displayName: $0.exposureDisplayName) })
                ?? [],
            validUntil: nil,
            canBeDeleted: false,
            discountId: UUID().uuidString
        )
    }

    init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discountDto discount: ReedeemedCampaingDTO?
    ) {
        self.init(
            id: UUID().uuidString,
            code: data.code ?? discount?.code ?? "",
            amount: .init(fragment: data.discount.fragments.moneyFragment),
            title: discount?.description ?? "",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: false,
            discountId: UUID().uuidString
        )
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

@MainActor
extension PaymentDiscountsData {
    init(with data: OctopusGraphQL.DiscountsQuery.Data) {
        self.init(
            discounts: data.currentMember.redeemedCampaigns.filter({ $0.type == .voucher })
                .compactMap({ .init(with: $0) }),
            referralsData: .init(with: data.currentMember.referralInformation)
        )
    }
}

@MainActor
extension Discount {
    init(with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.RedeemedCampaign) {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        let amountFromPaymentData = store.state.paymentData?.discounts.first(where: { $0.code == data.code })?.amount
        self.init(
            id: UUID().uuidString,
            code: data.code,
            amount: amountFromPaymentData,
            title: data.description,
            listOfAffectedInsurances: data.onlyApplicableToContracts?
                .compactMap({ .init(id: $0.id, displayName: $0.exposureDisplayName) }) ?? [],
            validUntil: data.expiresAt,
            canBeDeleted: true,
            discountId: data.id
        )
    }
}

extension ReferralsData {
    init(with data: OctopusGraphQL.DiscountsQuery.Data.CurrentMember.ReferralInformation) {
        var referrals: [Referral] = []
        if let invitedBy = data.referredBy?.fragments.memberReferralFragment2 {
            referrals.append(.init(with: invitedBy, invitedYou: true))
        }
        referrals.append(contentsOf: data.referrals.compactMap({ .init(with: $0.fragments.memberReferralFragment2) }))
        self.init(
            code: data.code,
            discountPerMember: .init(fragment: data.monthlyDiscountPerReferral.fragments.moneyFragment),
            discount: .sek(10),
            referrals: referrals.reversed()
        )
    }
}

extension Referral {
    init(with data: OctopusGraphQL.MemberReferralFragment2, invitedYou: Bool = false) {
        self.init(
            id: UUID().uuidString,
            name: data.name,
            activeDiscount: .init(optionalFragment: data.activeDiscount?.fragments.moneyFragment),
            status: data.status.asReferralState,
            invitedYou: invitedYou
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.MemberReferralStatus> {
    var asReferralState: Referral.State {
        switch self {
        case .case(let t):
            switch t {
            case .pending:
                return .pending
            case .active:
                return .active
            case .terminated:
                return .terminated
            }
        case .unknown:
            return .unknown
        }
    }
}

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
        let chargeFragment = data
        let redeemedCampaigns = campaings.redeemedCampaigns
        self.init(
            id: data.id ?? "",
            payment: .init(with: chargeFragment),
            status: PaymentData.PaymentStatus.getStatus(with: chargeFragment, and: nextPayment),
            contracts: chargeFragment.chargeBreakdown.compactMap({ .init(with: $0) }),
            discounts: chargeFragment.discountBreakdown.compactMap({ discountBreakdown in
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
            }),
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

extension Discount {
    init(
        with data: OctopusGraphQL.MemberChargeFragment.DiscountBreakdown,
        discount: OctopusGraphQL.ReedemCampaignsFragment.RedeemedCampaign?
    ) {
        self.init(
            id: UUID().uuidString,
            code: data.code ?? discount?.code ?? "",
            amount: .init(fragment: data.discount.fragments.moneyFragment),
            title: discount?.description ?? "",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: false,
            discountId: UUID().uuidString
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

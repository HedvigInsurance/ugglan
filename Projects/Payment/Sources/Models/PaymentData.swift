import Campaign
import Contracts
import Foundation
import hCore
import hCoreUI

public struct PaymentData: Codable, Equatable, Hashable, Sendable {
    let id: String
    public let payment: PaymentStack
    let status: PaymentStatus
    let contracts: [ContractPaymentDetails]
    public let discounts: [Discount]
    let paymentDetails: PaymentDetails?
    //had to add as an array since we can't nest same struct type here
    let addedToThePayment: [PaymentData]?

    public init(
        id: String,
        payment: PaymentStack,
        status: PaymentStatus,
        contracts: [ContractPaymentDetails],
        discounts: [Discount],
        paymentDetails: PaymentDetails?,
        addedToThePayment: [PaymentData]?
    ) {
        self.id = id
        self.payment = payment
        self.status = status
        self.contracts = contracts
        self.discounts = discounts
        self.paymentDetails = paymentDetails
        self.addedToThePayment = addedToThePayment
    }

    public struct PaymentStack: Codable, Equatable, Hashable, Sendable {
        let gross: MonetaryAmount
        let net: MonetaryAmount
        let carriedAdjustment: MonetaryAmount?
        let settlementAdjustment: MonetaryAmount?
        public let date: ServerBasedDate

        public init(
            gross: MonetaryAmount,
            net: MonetaryAmount,
            carriedAdjustment: MonetaryAmount?,
            settlementAdjustment: MonetaryAmount?,
            date: ServerBasedDate
        ) {
            self.gross = gross
            self.net = net
            self.carriedAdjustment = carriedAdjustment
            self.settlementAdjustment = settlementAdjustment
            self.date = date
        }
    }

    public enum PaymentStatus: Codable, Equatable, Hashable, Sendable {
        case upcoming
        case success
        case pending
        case failedForPrevious(from: ServerBasedDate, to: ServerBasedDate)
        case addedtoFuture(date: ServerBasedDate)
        case unknown

        enum PaymentStatusAction: Codable, Equatable, Hashable {
            static func == (lhs: PaymentStatusAction, rhs: PaymentStatusAction) -> Bool {
                return false
            }
            case viewAddedToPayment
        }

        var hasFailed: Bool {
            switch self {
            case .addedtoFuture:
                return true
            case .success, .pending, .failedForPrevious, .upcoming, .unknown:
                return false
            }
        }
    }

    public struct ContractPaymentDetails: Codable, Equatable, Identifiable, Hashable, Sendable {
        public let id: String
        let title: String
        let subtitle: String?
        let amount: MonetaryAmount
        let periods: [PeriodInfo]

        public init(id: String, title: String, subtitle: String?, amount: MonetaryAmount, periods: [PeriodInfo]) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.amount = amount
            self.periods = periods
        }
    }

    public struct PeriodInfo: Codable, Equatable, Identifiable, Hashable, Sendable {
        public let id: String
        let from: ServerBasedDate
        let to: ServerBasedDate
        let amount: MonetaryAmount
        let isOutstanding: Bool
        let desciption: String?

        public init(
            id: String,
            from: ServerBasedDate,
            to: ServerBasedDate,
            amount: MonetaryAmount,
            isOutstanding: Bool,
            desciption: String?
        ) {
            self.id = id
            self.from = from
            self.to = to
            self.amount = amount
            self.isOutstanding = isOutstanding
            self.desciption = desciption
        }

        @MainActor
        var fromToDate: String {
            return "\(from.displayDateShort) - \(to.displayDateShort)"
        }
    }

    public struct PaymentDetails: Codable, Equatable, Hashable, Sendable {
        typealias KeyValue = (key: String, value: String)
        let paymentMethod: String
        let account: String
        let bank: String

        public init(paymentMethod: String, account: String, bank: String) {
            self.paymentMethod = paymentMethod
            self.account = account
            self.bank = bank
        }

        var getDisplayList: [KeyValue] {
            var list: [KeyValue] = []
            list.append((L10n.paymentsPaymentMethod, paymentMethod))
            list.append((L10n.paymentsAccount, account))
            list.append((L10n.myPaymentBankRowLabel, bank))

            return list
        }
    }
}

extension PaymentData: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: PaymentDetailsView.self)
    }
}

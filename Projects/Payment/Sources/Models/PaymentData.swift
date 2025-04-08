import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct PaymentData: Codable, Equatable, Hashable, Sendable {
    let id: String
    let payment: PaymentStack
    let status: PaymentStatus
    let contracts: [ContractPaymentDetails]
    let discounts: [Discount]
    let paymentDetails: PaymentDetails?
    //had to add as an array since we can't nest same struct type here
    let addedToThePayment: [PaymentData]?

    struct PaymentStack: Codable, Equatable, Hashable, Sendable {
        let gross: MonetaryAmount
        let net: MonetaryAmount
        let carriedAdjustment: MonetaryAmount?
        let settlementAdjustment: MonetaryAmount?
        let date: ServerBasedDate
    }

    enum PaymentStatus: Codable, Equatable, Hashable, Sendable {
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

    struct ContractPaymentDetails: Codable, Equatable, Identifiable, Hashable, Sendable {
        let id: String
        let title: String
        let subtitle: String?
        let amount: MonetaryAmount
        let periods: [PeriodInfo]
    }

    struct PeriodInfo: Codable, Equatable, Identifiable, Hashable, Sendable {
        let id: String
        let from: ServerBasedDate
        let to: ServerBasedDate
        let amount: MonetaryAmount
        let isOutstanding: Bool
        let desciption: String?

        @MainActor
        var fromToDate: String {
            return "\(from.displayDateShort) - \(to.displayDateShort)"
        }
    }

    struct PaymentDetails: Codable, Equatable, Hashable, Sendable {
        typealias KeyValue = (key: String, value: String)
        let paymentMethod: String
        let account: String
        let bank: String

        init(paymentMethod: String, account: String, bank: String) {
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

public struct Discount: Codable, Equatable, Identifiable, Hashable, Sendable {
    public let id = UUID().uuidString
    let code: String
    let amount: MonetaryAmount?
    let title: String?
    let listOfAffectedInsurances: [AffectedInsurance]
    let validUntil: ServerBasedDate?
    let canBeDeleted: Bool
    let discountId: String

    @MainActor
    var isValid: Bool {
        if let validUntil = validUntil?.localDateToDate {
            let components = Calendar.current.dateComponents(
                [.day],
                from: Date(),
                to: validUntil
            )
            let isValid = components.day ?? 0 >= 0
            return isValid
        }
        return true
    }
}

public struct AffectedInsurance: Codable, Equatable, Identifiable, Hashable, Sendable {
    public let id: String
    let displayName: String
}

extension PaymentData: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: PaymentDetailsView.self)
    }
}

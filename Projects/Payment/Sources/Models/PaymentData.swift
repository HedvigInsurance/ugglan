import Contracts
import Foundation
import hCore
import hGraphQL

public struct PaymentData: Codable, Equatable {
    let id: String
    let payment: PaymentStack
    let status: PaymentStatus
    let contracts: [ContractPaymentDetails]
    let discounts: [Discount]
    let paymentDetails: PaymentDetails?
    //had to add as an array since we can't nest same struct type here
    let addedToThePayment: [PaymentData]?
    struct PaymentStack: Codable, Equatable {
        let gross: MonetaryAmount
        let net: MonetaryAmount
        let date: ServerBasedDate
    }

    enum PaymentStatus: Codable, Equatable {
        case upcoming
        case success
        case pending
        case failedForPrevious(from: ServerBasedDate, to: ServerBasedDate)
        case addedtoFuture(date: ServerBasedDate)
        case unknown

        enum PaymentStatusAction: Codable, Equatable {
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

    struct ContractPaymentDetails: Codable, Equatable, Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let amount: MonetaryAmount
        let periods: [PeriodInfo]
    }

    struct PeriodInfo: Codable, Equatable, Identifiable {
        let id: String
        let from: ServerBasedDate
        let to: ServerBasedDate
        let amount: MonetaryAmount
        let isOutstanding: Bool

        var fromToDate: String {
            return "\(from.displayDateShort) - \(to.displayDateShort)"
        }
    }

    struct PaymentDetails: Codable, Equatable {
        typealias KeyValue = (key: String, value: String)
        private let paymentMethod: String
        private let account: String
        private let bank: String

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

public struct Discount: Codable, Equatable, Identifiable {
    public let id: String
    let code: String
    let amount: MonetaryAmount?
    let title: String
    let listOfAffectedInsurances: [AffectedInsurance]
    let validUntil: ServerBasedDate?
    let canBeDeleted: Bool

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

public struct AffectedInsurance: Codable, Equatable, Identifiable {
    public let id: String
    let displayName: String
}

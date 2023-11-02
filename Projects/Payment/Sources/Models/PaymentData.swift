import Contracts
import Foundation
import hCore
import hGraphQL

public struct PaymentData: Codable, Equatable {
    let upcomingPayment: UpcomingPayment?
    let previousPaymentStatus: PreviousPaymentStatus?
    let contracts: [ContractPaymentDetails]
    let discounts: [Discounts]

    struct UpcomingPayment: Codable, Equatable {
        let gross: MonetaryAmount
        let net: MonetaryAmount
        let date: ServerBasedDate
    }

    enum PreviousPaymentStatus: Codable, Equatable {
        case success
        case pending
        case failed(from: ServerBasedDate, to: ServerBasedDate, until: ServerBasedDate)
    }

    struct ContractPaymentDetails: Codable, Equatable {
        let title: String
        let subtitle: String
        let amount: MonetaryAmount
        let perions: [PeriodInfo]
    }

    struct PeriodInfo: Codable, Equatable {
        let from: ServerBasedDate
        let to: ServerBasedDate
        let amount: MonetaryAmount
        let isOutstanding: Bool
    }
}

public struct Discounts: Codable, Equatable {
    let code: String
    let amount: MonetaryAmount
    let title: String
    let subtitle: String?
    let validUntil: ServerBasedDate
}

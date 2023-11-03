import Contracts
import Foundation
import hCore
import hGraphQL

public struct PaymentData: Codable, Equatable {
    let upcomingPayment: UpcomingPayment?
    let previousPaymentStatus: PreviousPaymentStatus?

    struct UpcomingPayment: Codable, Equatable {
        let amount: MonetaryAmount
        let date: ServerBasedDate
    }

    enum PreviousPaymentStatus: Codable, Equatable {
        case success
        case pending
        case failed(from: ServerBasedDate, to: ServerBasedDate)
    }
}

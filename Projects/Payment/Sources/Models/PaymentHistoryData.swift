import Foundation
import hCore
import hGraphQL

public struct PaymentHistoryListData: Codable, Equatable, Identifiable {
    public let id: String
    let year: String
    let valuesPerMonth: [PaymentHistory]
}

struct PaymentHistory: Codable, Equatable, Identifiable {
    let id: String
    let date: ServerBasedDate
    let amount: MonetaryAmount
    let paymentData: PaymentData
}

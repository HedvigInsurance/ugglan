import Foundation
import hCore
import hGraphQL

public struct PaymentHistoryListData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    let year: String
    let valuesPerMonth: [PaymentHistory]
}

struct PaymentHistory: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let paymentData: PaymentData
}

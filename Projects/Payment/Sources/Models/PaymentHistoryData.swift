import Foundation

public struct PaymentHistoryListData: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    let year: String
    let valuesPerMonth: [PaymentHistory]

    public init(id: String, year: String, valuesPerMonth: [PaymentHistory]) {
        self.id = id
        self.year = year
        self.valuesPerMonth = valuesPerMonth
    }
}

public struct PaymentHistory: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let paymentData: PaymentData

    public init(id: String, paymentData: PaymentData) {
        self.id = id
        self.paymentData = paymentData
    }
}

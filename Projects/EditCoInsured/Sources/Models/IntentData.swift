import Foundation
import hCore

public struct Intent: Sendable {
    let activationDate: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let id: String

    public init(
        activationDate: String,
        currentPremium: MonetaryAmount,
        newPremium: MonetaryAmount,
        id: String
    ) {
        self.activationDate = activationDate
        self.currentPremium = currentPremium
        self.newPremium = newPremium
        self.id = id
    }
}

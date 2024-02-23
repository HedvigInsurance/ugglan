import Foundation
import hGraphQL

public struct Intent {
    let activationDate: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let id: String
    let state: String
}

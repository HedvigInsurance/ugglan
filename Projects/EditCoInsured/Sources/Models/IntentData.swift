import Foundation
import hGraphQL

public struct IntentData {
    let intent: Intent?
    let userErrorMessage: String?

    init(
        activationDate: String,
        currentPremium: MonetaryAmount,
        newPremium: MonetaryAmount,
        id: String,
        state: String
    ) {
        self.intent = Intent(
            activationDate: activationDate,
            currentPremium: currentPremium,
            newPremium: newPremium,
            id: id,
            state: state
        )
        self.userErrorMessage = nil
    }

    init(
        userErrorMessage: String
    ) {
        self.intent = nil
        self.userErrorMessage = userErrorMessage
    }
}

public struct Intent {
    let activationDate: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let id: String
    let state: String
}

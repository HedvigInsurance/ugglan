import Apollo
import Flow
import Foundation
import Offer
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PaymentState: StateProtocol {
    var monthlyNetCost: MonetaryAmount? = nil
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setMonthlyNetCost(cost: MonetaryAmount)
}

public final class PaymentStore: StateStore<PaymentState, PaymentAction> {
    @Inject var client: ApolloClient

    public override func effects(
        _ getState: @escaping () -> PaymentState,
        _ action: PaymentAction
    ) -> FiniteSignal<PaymentAction>? {
        switch action {
        case .load:
            return client.fetch(
                query: GraphQL.MyPaymentQuery()
            ).compactMap { data in
                if let fragment = data.insuranceCost?.monthlyNet.fragments.monetaryAmountFragment {
                    return .setMonthlyNetCost(cost: MonetaryAmount(fragment: fragment))
                }
                
                return nil
            }.valueThenEndSignal
        default:
            return nil
        }
    }

    public override func reduce(_ state: PaymentState, _ action: PaymentAction) -> PaymentState {
        var newState = state

        switch action {
        case let .setMonthlyNetCost(cost):
            newState.monthlyNetCost = cost
        default:
            break
        }

        return newState
    }
}

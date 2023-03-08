import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PaymentState: StateProtocol {
    var monthlyNetCost: MonetaryAmount? = nil
    var paymentConnectionID: String? = nil
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setMonthlyNetCost(cost: MonetaryAmount)
    case setConnectionID(id: String)
}

public final class PaymentStore: StateStore<PaymentState, PaymentAction> {
    @Inject var giraffe: hGiraffe

    public override func effects(
        _ getState: @escaping () -> PaymentState,
        _ action: PaymentAction
    ) -> FiniteSignal<PaymentAction>? {
        switch action {
        case .load:
            return giraffe.client
                .fetch(
                    query: GiraffeGraphQL.MyPaymentQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .compactMap { data in
                    if let fragment = data.insuranceCost?.monthlyNet.fragments.monetaryAmountFragment {
                        return .setMonthlyNetCost(cost: MonetaryAmount(fragment: fragment))
                    }

                    return nil
                }
                .valueThenEndSignal
        default:
            return nil
        }
    }

    public override func reduce(_ state: PaymentState, _ action: PaymentAction) -> PaymentState {
        var newState = state

        switch action {
        case let .setMonthlyNetCost(cost):
            newState.monthlyNetCost = cost
        case let .setConnectionID(id):
            newState.paymentConnectionID = id
        default:
            break
        }

        return newState
    }
}

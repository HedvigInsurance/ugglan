import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PaymentState: StateProtocol {
    var monthlyNetCost: MonetaryAmount? = nil
    var paymentStatus: PayinMethodStatus = .active
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setMonthlyNetCost(cost: MonetaryAmount)
    case setPayInMethodStatus(status: PayinMethodStatus)
    case connectPayments
    case fetchPayInMethodStatus
}

public typealias PayinMethodStatus = GraphQL.PayinMethodStatus
extension PayinMethodStatus: Codable {}

public final class PaymentStore: StateStore<PaymentState, PaymentAction> {
    @Inject var client: ApolloClient

    public override func effects(
        _ getState: @escaping () -> PaymentState,
        _ action: PaymentAction
    ) -> FiniteSignal<PaymentAction>? {
        switch action {
        case .load:
            return
                client.fetch(
                    query: GraphQL.MyPaymentQuery()
                )
                .compactMap { data in
                    if let fragment = data.insuranceCost?.monthlyNet.fragments.monetaryAmountFragment {
                        return .setMonthlyNetCost(cost: MonetaryAmount(fragment: fragment))
                    }

                    return nil
                }
                .valueThenEndSignal
        case .fetchPayInMethodStatus:
            return
                client
                .fetch(query: GraphQL.PayInMethodStatusQuery(), cachePolicy: .fetchIgnoringCacheData)
                .map { data in
                    .setPayInMethodStatus(status: data.payinMethodStatus)
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
        case .setPayInMethodStatus(let paymentStatus):
            newState.paymentStatus = paymentStatus
        default:
            break
        }

        return newState
    }
}

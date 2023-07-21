import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PaymentState: StateProtocol {
    var paymentData: PaymentData?
    var monthlyNetCost: MonetaryAmount? = nil
    public var paymentStatus: PayinMethodStatus = .active
    var paymentConnectionID: String? = nil
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setMonthlyNetCost(cost: MonetaryAmount)
    case setPaymentData(data: PaymentData)
    case setPayInMethodStatus(status: PayinMethodStatus)
    case connectPayments
    case fetchPayInMethodStatus
    case setConnectionID(id: String)
    case openHistory
    case openConnectBankAccount
}

public typealias PayinMethodStatus = GiraffeGraphQL.PayinMethodStatus
extension PayinMethodStatus: Codable {}

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
                    ),
                    cachePolicy: .fetchIgnoringCacheCompletely
                )
                .compactMap { data in
                    let paymentData = PaymentData(data)
                    return .setPaymentData(data: paymentData)
                }
                .valueThenEndSignal
        case .fetchPayInMethodStatus:
            return giraffe
                .client
                .fetch(query: GiraffeGraphQL.PayInMethodStatusQuery(), cachePolicy: .fetchIgnoringCacheData)
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
        case let .setPaymentData(data):
            newState.paymentData = data
            newState.monthlyNetCost = data.net
        case let .setMonthlyNetCost(cost):
            newState.monthlyNetCost = cost
        case .setPayInMethodStatus(let paymentStatus):
            newState.paymentStatus = paymentStatus
        case let .setConnectionID(id):
            newState.paymentConnectionID = id
        default:
            break
        }

        return newState
    }
}

public struct PaymentData: Codable, Equatable {
    let nextPayment: NextPayment?
    let contracts: [Contract]?
    let code: String?
    let gross: MonetaryAmount?
    let discount: MonetaryAmount?
    let net: MonetaryAmount?
    let paymentHistory: [PaymentHistory]?
    let bankAccount: BankAccount?
    let status: GiraffeGraphQL.PayinMethodStatus

    init(_ data: GiraffeGraphQL.MyPaymentQuery.Data) {
        nextPayment = NextPayment(data)
        contracts = [.init(id: "1", type: .accident, name: "NAME", amount: .sek(20))]
        code = nil
        gross = MonetaryAmount(fragment: data.chargeEstimation.subscription.fragments.monetaryAmountFragment)
        discount = MonetaryAmount(fragment: data.chargeEstimation.discount.fragments.monetaryAmountFragment)
        net = MonetaryAmount(fragment: data.chargeEstimation.charge.fragments.monetaryAmountFragment)
        paymentHistory = data.chargeHistory.map({ PaymentHistory($0) })
        bankAccount = BankAccount(data.bankAccount)
        status = data.payinMethodStatus
    }

    struct NextPayment: Codable, Equatable {
        let amount: MonetaryAmount?
        let date: String?

        init(_ data: GiraffeGraphQL.MyPaymentQuery.Data) {
            amount = MonetaryAmount(fragment: data.chargeEstimation.charge.fragments.monetaryAmountFragment)
            date = data.nextChargeDate
        }
    }

    struct Contract: Codable, Equatable {
        let id: String
        let type: hGraphQL.Contract.PillowType
        let name: String
        let amount: MonetaryAmount?
    }

    struct PaymentHistory: Codable, Equatable {
        let amount: MonetaryAmount
        let date: String

        init(_ data: GiraffeGraphQL.MyPaymentQuery.Data.ChargeHistory) {
            amount = MonetaryAmount(fragment: data.amount.fragments.monetaryAmountFragment)
            let localDate = data.date.localDateToDate?.displayDateMMMDDYYYYFormat ?? ""
            date = localDate
        }
    }

    struct BankAccount: Codable, Equatable {
        let name: String?
        let descriptor: String?

        init?(_ data: GiraffeGraphQL.MyPaymentQuery.Data.BankAccount?) {
            guard let data else { return nil }
            name = data.bankName
            descriptor = data.descriptor
        }
    }
}

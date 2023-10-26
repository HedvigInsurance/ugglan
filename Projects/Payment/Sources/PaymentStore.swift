import Apollo
import Contracts
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PaymentState: StateProtocol {
    var paymentData: PaymentData?
    var monthlyNetCost: MonetaryAmount? = nil
    public var paymentStatusData: PaymentStatusData? = nil
    var paymentConnectionID: String? = nil
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setMonthlyNetCost(cost: MonetaryAmount)
    case setPaymentData(data: PaymentData)
    case fetchPaymentStatus
    case setPaymentStatus(data: PaymentStatusData)
    case connectPayments
    case setConnectionID(id: String)
    case openHistory
    case openConnectBankAccount
    case openUrl
    case goBack
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
}

extension PayinMethodStatus: Codable {}

public final class PaymentStore: LoadingStateStore<PaymentState, PaymentAction, LoadingAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> PaymentState,
        _ action: PaymentAction
    ) -> FiniteSignal<PaymentAction>? {
        switch action {
        case .load:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetch(
                        query: GiraffeGraphQL.MyPaymentQuery(
                            locale: Localization.Locale.currentLocale.asGraphQLLocale()
                        ),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue({ data in
                        let paymentData = PaymentData(data)
                        callback(.value(.setPaymentData(data: paymentData)))
                    })
                    .onError({ error in
                        self.setError(error.localizedDescription, for: .getPaymentData)
                    })
                return disposeBag
            }
        case .fetchPaymentStatus:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.PaymentInformationQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue({ data in
                        let paymentStatus = PaymentStatusData(data: data)
                        callback(.value(.setPaymentStatus(data: paymentStatus)))
                    })
                    .onError({ error in
                        self.setError(error.localizedDescription, for: .getPaymentStatus)
                    })
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: PaymentState, _ action: PaymentAction) -> PaymentState {
        var newState = state

        switch action {
        case .load:
            setLoading(for: .getPaymentData)
        case let .setPaymentData(data):
            removeLoading(for: .getPaymentData)
            newState.paymentData = data
            newState.monthlyNetCost = data.chargeEstimation?.net
        case let .setMonthlyNetCost(cost):
            newState.monthlyNetCost = cost
        case let .setConnectionID(id):
            newState.paymentConnectionID = id
        case .fetchPaymentStatus:
            setLoading(for: .getPaymentStatus)
        case let .setPaymentStatus(data):
            removeLoading(for: .getPaymentStatus)
            newState.paymentStatusData = data
        default:
            break
        }
        return newState
    }
}

public struct PaymentData: Codable, Equatable {
    let nextPayment: NextPayment?
    let contracts: [ContractInfo]?
    let insuranceCost: MonetaryStack?
    let chargeEstimation: MonetaryStack?
    let paymentHistory: [PaymentHistory]?
    let balance: Balance?
    var reedemCampaigns: [ReedemCampaign]
    init(_ data: GiraffeGraphQL.MyPaymentQuery.Data) {
        nextPayment = NextPayment(data)
        contracts = data.activeContractBundles.first?.contracts.map({ .init($0) }) ?? []
        insuranceCost = MonetaryStack(data.insuranceCost)
        chargeEstimation = MonetaryStack(data.chargeEstimation)
        paymentHistory = data.chargeHistory.map({ PaymentHistory($0) })
        balance = .init(data.balance)
        reedemCampaigns = data.redeemedCampaigns.compactMap({ .init($0) })
    }

    struct NextPayment: Codable, Equatable {
        let amount: MonetaryAmount?
        let date: String?

        init(_ data: GiraffeGraphQL.MyPaymentQuery.Data) {
            amount = MonetaryAmount(
                optionalFragment: data.insuranceCost?.monthlyNet.fragments.monetaryAmountFragmentGiraffe
            )
            date = data.nextChargeDate?.localDateToDate?.displayDateMMMDDYYYYFormat
        }
    }

    struct ContractInfo: Codable, Equatable {
        let id: String
        let type: Contract.TypeOfContract
        let name: String
        let amount: MonetaryAmount?

        init(_ data: GiraffeGraphQL.MyPaymentQuery.Data.ActiveContractBundle.Contract) {
            self.id = data.id
            self.name = data.displayName
            self.type = Contract.TypeOfContract(rawValue: data.typeOfContract.rawValue) ?? .unknown
            self.amount = nil
        }
    }

    struct PaymentHistory: Codable, Equatable {
        let amount: MonetaryAmount
        let date: String

        init(_ data: GiraffeGraphQL.MyPaymentQuery.Data.ChargeHistory) {
            amount = MonetaryAmount(fragment: data.amount.fragments.monetaryAmountFragmentGiraffe)
            let localDate = data.date.localDateToDate?.displayDateMMMDDYYYYFormat ?? ""
            date = localDate
        }
    }

    struct Balance: Codable, Equatable {
        let failedCharges: Int?
        let balance: MonetaryAmount?
        init?(_ data: GiraffeGraphQL.MyPaymentQuery.Data.Balance?) {
            guard let data else { return nil }
            failedCharges = data.failedCharges
            balance = .init(fragment: data.currentBalance.fragments.monetaryAmountFragmentGiraffe)
        }
    }

    struct ReedemCampaign: Codable, Equatable {
        let code: String?
        let displayValue: String?
        init?(_ data: GiraffeGraphQL.MyPaymentQuery.Data.RedeemedCampaign?) {
            guard let data else { return nil }
            code = data.code
            displayValue = data.displayValue
        }
    }

    struct MonetaryStack: Codable, Equatable {
        let gross: MonetaryAmount?
        let discount: MonetaryAmount?
        let net: MonetaryAmount?

        init?(_ data: GiraffeGraphQL.MyPaymentQuery.Data.InsuranceCost?) {
            guard let data else { return nil }
            self.gross = MonetaryAmount(fragment: data.monthlyGross.fragments.monetaryAmountFragmentGiraffe)
            self.discount = MonetaryAmount(fragment: data.monthlyDiscount.fragments.monetaryAmountFragmentGiraffe)
            self.net = MonetaryAmount(fragment: data.monthlyNet.fragments.monetaryAmountFragmentGiraffe)
        }

        init?(_ data: GiraffeGraphQL.MyPaymentQuery.Data.ChargeEstimation?) {
            guard let data else { return nil }
            self.gross = MonetaryAmount(fragment: data.subscription.fragments.monetaryAmountFragmentGiraffe)
            self.discount = MonetaryAmount(fragment: data.discount.fragments.monetaryAmountFragmentGiraffe)
            self.net = MonetaryAmount(fragment: data.charge.fragments.monetaryAmountFragmentGiraffe)
        }
    }
}

public struct PaymentStatusData: Codable, Equatable {
    public var status: PayinMethodStatus = .active
    public var failedCharges: Int?
    public var nextChargeDate: String?
    let displayName: String?
    let descriptor: String?

    init(data: OctopusGraphQL.PaymentInformationQuery.Data) {
        self.status = data.currentMember.paymentInformation.status.asPayinMethodStatus
        self.displayName = data.currentMember.paymentInformation.connection?.displayName
        self.descriptor = data.currentMember.paymentInformation.connection?.descriptor
        self.failedCharges = 0  //data.balance.failedCharges
        self.nextChargeDate = nil  //data.nextChargeDate
    }
}

extension OctopusGraphQL.MemberPaymentConnectionStatus {
    var asPayinMethodStatus: PayinMethodStatus {
        switch self {
        case .active:
            return .active
        case .pending:
            return .pending
        case .needsSetup:
            return .needsSetup
        case .__unknown:
            return .unknown
        }
    }
}

public enum PayinMethodStatus {
    case active
    case needsSetup
    case pending
    case unknown
}

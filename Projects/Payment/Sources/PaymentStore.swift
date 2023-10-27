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
    public var paymentStatusData: PaymentStatusData? = nil
    var paymentConnectionID: String? = nil
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
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
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> PaymentState,
        _ action: PaymentAction
    ) -> FiniteSignal<PaymentAction>? {
        switch action {
        case .load:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.PaymentDataQuery(),
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
    var reedemCampaigns: [ReedemCampaign]
    init(_ data: OctopusGraphQL.PaymentDataQuery.Data) {
        let currentMember = data.currentMember
        nextPayment = NextPayment(currentMember.upcomingCharge)
        contracts = currentMember.upcomingCharge?.contractsChargeBreakdown.map({ .init($0) }) ?? []
        insuranceCost = MonetaryStack(currentMember.insuranceCost)
        chargeEstimation = MonetaryStack(currentMember.upcomingCharge)
        paymentHistory = currentMember.chargeHistory.map({ PaymentHistory($0) })
        reedemCampaigns = currentMember.redeemedCampaigns.compactMap({ .init($0) })
    }

    struct NextPayment: Codable, Equatable {
        let amount: MonetaryAmount?
        let date: String?

        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.UpcomingCharge?) {
            guard let data else { return nil }
            amount = MonetaryAmount(optionalFragment: data.net.fragments.moneyFragment)
            date = data.date
        }
    }

    struct ContractInfo: Codable, Equatable {
        let id: String
        let type: Contract.TypeOfContract
        let name: String
        let amount: MonetaryAmount?

        init(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.UpcomingCharge.ContractsChargeBreakdown) {
            self.id = data.contract.id
            self.name = data.contract.exposureDisplayName
            self.type =
                Contract.TypeOfContract(rawValue: data.contract.currentAgreement.productVariant.typeOfContract)
                ?? .unknown
            //            self.amount = MonetaryAmount(fragment: data.contract.currentAgreement.premium.fragments.moneyFragment)
            self.amount = MonetaryAmount(fragment: data.gross.fragments.moneyFragment)
        }
    }

    struct PaymentHistory: Codable, Equatable {
        let amount: MonetaryAmount
        let date: String

        init(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.ChargeHistory) {
            amount = MonetaryAmount(fragment: data.amount.fragments.moneyFragment)
            let localDate = data.date
            date = localDate
        }
    }

    struct ReedemCampaign: Codable, Equatable {
        let code: String?
        let displayValue: String?
        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.RedeemedCampaign?) {
            guard let data else { return nil }
            code = data.code
            displayValue = data.description
        }
    }

    struct MonetaryStack: Codable, Equatable {
        let gross: MonetaryAmount?
        let discount: MonetaryAmount?
        let net: MonetaryAmount?

        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.UpcomingCharge?) {
            guard let data else { return nil }
            self.gross = MonetaryAmount(fragment: data.gross.fragments.moneyFragment)
            self.discount = MonetaryAmount(fragment: data.discount.fragments.moneyFragment)
            self.net = MonetaryAmount(fragment: data.net.fragments.moneyFragment)
        }

        init?(_ data: OctopusGraphQL.PaymentDataQuery.Data.CurrentMember.InsuranceCost) {
            self.gross = MonetaryAmount(fragment: data.monthlyGross.fragments.moneyFragment)
            self.discount = MonetaryAmount(fragment: data.monthlyDiscount.fragments.moneyFragment)
            self.net = MonetaryAmount(fragment: data.monthlyNet.fragments.moneyFragment)
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

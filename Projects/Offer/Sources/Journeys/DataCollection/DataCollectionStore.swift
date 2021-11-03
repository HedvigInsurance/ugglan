import Apollo
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hGraphQL

public enum DataCollectionStatus: Codable {
    case none
    case started
    case login
    case collecting
    case completed
    case failed
}

public enum DataCollectionAuthMethod: Equatable, Codable {
    case swedishBankIDEphemeral
    case swedishBankIDAutoStartToken(token: String)
    case norwegianBankIDWords(words: String)
}

public struct DataCollectionState: StateProtocol {
    var providerID: String? = nil
    var providerDisplayName: String? = nil
    var id: UUID? = nil
    var status = DataCollectionStatus.none
    var authMethod: DataCollectionAuthMethod? = nil
    var market: Localization.Locale.Market
    var personalNumber: String? = nil
    var netPremium: MonetaryAmount? = nil

    public init() {
        self.market = Localization.Locale.currentLocale.market
    }
}

public enum DataCollectionAction: ActionProtocol {
    case setProvider(providerID: String, providerDisplayName: String)
    case didIntroDecide(decision: DataCollectionIntroDecision)
    case confirmResult(result: DataCollectionConfirmationResult)
    case setPersonalNumber(personalNumber: String)
    case startAuthentication
    case setStatus(status: DataCollectionStatus)
    case setAuthMethod(method: DataCollectionAuthMethod)
    case fetchInfo
    case setNetPremium(amount: MonetaryAmount?)
}

public final class DataCollectionStore: StateStore<DataCollectionState, DataCollectionAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    func dataCollectionSubscription(for reference: String) -> FiniteSignal<DataCollectionAction> {
        FiniteSignal { callback in
            let bag = DisposeBag()

            bag += self.client.subscribe(subscription: GraphQL.DataCollectionSubscription(reference: reference))
                .onValue({ data in
                    if let extraInformation = data.dataCollectionStatusV2.extraInformation?.asSwedishBankIdExtraInfo {
                        if let token = extraInformation.autoStartToken {
                            callback(
                                .value(
                                    .setAuthMethod(
                                        method: .swedishBankIDAutoStartToken(token: token)
                                    )
                                )
                            )
                        }
                    } else if let extraInformation = data.dataCollectionStatusV2.extraInformation?
                        .asNorwegianBankIdExtraInfo
                    {
                        callback(
                            .value(
                                .setAuthMethod(
                                    method: .norwegianBankIDWords(words: extraInformation.norwegianBankIdWords ?? "")
                                )
                            )
                        )
                    } else {
                        callback(
                            .value(
                                .setAuthMethod(
                                    method: .swedishBankIDEphemeral
                                )
                            )
                        )
                    }

                    switch data.dataCollectionStatusV2.status {
                    case .running:
                        callback(.value(.setStatus(status: .none)))
                    case .login:
                        callback(.value(.setStatus(status: .login)))
                    case .collecting:
                        callback(.value(.setStatus(status: .collecting)))
                    case .completedEmpty, .completed, .completedPartial:
                        callback(.value(.setStatus(status: .completed)))
                        callback(.end)
                    case .failed, .waitingForAuthentication:
                        callback(.value(.setStatus(status: .failed)))
                        callback(.end)
                    case .__unknown(_), .userInput:
                        callback(.end)
                    }
                })

            return bag
        }
    }

    public override func effects(
        _ getState: @escaping () -> DataCollectionState,
        _ action: DataCollectionAction
    ) -> FiniteSignal<DataCollectionAction>? {
        if case .startAuthentication = action,
            let reference = getState().id?.uuidString,
            let providerID = getState().providerID,
            let personalNumber = getState().personalNumber
        {
            cancelEffect(action)
            let market = getState().market

            return FiniteSignal { callback in
                let bag = DisposeBag()

                func startSubscription() {
                    bag += self.dataCollectionSubscription(for: reference)
                        .atValue { action in
                            callback(.value(action))
                        }
                        .onEnd {
                            callback(.end)
                        }
                }

                switch market {
                case .se:
                    bag += self.client
                        .perform(
                            mutation: GraphQL.DataCollectionSwedenMutation(
                                reference: reference,
                                provider: providerID,
                                personalNumber: personalNumber
                            )
                        )
                        .map { _ in DataCollectionAction.setStatus(status: .started) }
                        .onValue { action in
                            callback(.value(action))
                            startSubscription()
                        }
                case .no:
                    self.client
                        .perform(
                            mutation: GraphQL.DataCollectionNorwayMutation(
                                reference: reference,
                                provider: providerID,
                                personalNumber: personalNumber
                            )
                        )
                        .map { _ in DataCollectionAction.setStatus(status: .started) }
                        .onValue { action in
                            callback(.value(action))
                            startSubscription()
                        }
                case .dk:
                    break
                }

                return bag
            }
        } else if case .setStatus(status: .completed) = action {
            return [.fetchInfo].emitEachThenEnd
        } else if case .fetchInfo = action {
            return self.client.fetch(query: GraphQL.DataCollectionInfoQuery(reference: getState().id?.uuidString ?? ""))
                .map { data in
                    if let info = data.externalInsuranceProvider?.dataCollectionV2.first {
                        if let netPremiumFragment = info.asPersonTravelInsuranceCollection?.monthlyNetPremium?.fragments
                            .monetaryAmountFragment
                        {
                            return .setNetPremium(amount: MonetaryAmount(fragment: netPremiumFragment))
                        } else if let netPremiumFragment = info.asHouseInsuranceCollection?.monthlyNetPremium?.fragments
                            .monetaryAmountFragment
                        {
                            return .setNetPremium(amount: MonetaryAmount(fragment: netPremiumFragment))
                        }
                    }

                    return .setStatus(status: .failed)
                }
                .valueThenEndSignal
        }

        return nil
    }

    override public func reduce(_ state: DataCollectionState, _ action: DataCollectionAction) -> DataCollectionState {
        var newState = state

        switch action {
        case let .setProvider(providerID, providerDisplayName):
            newState.providerID = providerID
            newState.providerDisplayName = providerDisplayName
        case let .setPersonalNumber(personalNumber):
            newState.personalNumber = personalNumber
        case .startAuthentication:
            newState.id = UUID()
            newState.authMethod = nil
            newState.status = .none
        case let .setStatus(status):
            newState.status = status
        case let .setAuthMethod(method):
            newState.authMethod = method
        case let .setNetPremium(amount):
            newState.netPremium = amount
        default:
            break
        }

        return newState
    }
}

extension View {
    func mockProvider() -> some View {
        mockState(DataCollectionStore.self) { state in
            var newState = state
            newState.providerID = "Hedvig"
            newState.providerDisplayName = "Hedvig"
            return newState
        }
    }
}

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

    public init() {
        self.market = Localization.Locale.currentLocale.market
    }
}

public enum DataCollectionAction: ActionProtocol {
    case setProvider(providerID: String, providerDisplayName: String)
    case didIntroDecide(decision: DataCollectionIntroDecision)
    case confirmResult(result: DataCollectionConfirmationResult)
    case startAuthentication(personalNumber: String)
    case setStatus(status: DataCollectionStatus)
    case setAuthMethod(method: DataCollectionAuthMethod)
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
                    case .login:
                        callback(.value(.setStatus(status: .login)))
                    case .collecting, .running:
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
        if case let .startAuthentication(personalNumber) = action,
            let reference = getState().id?.uuidString,
            let providerID = getState().providerID
        {
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
        }

        return nil
    }

    override public func reduce(_ state: DataCollectionState, _ action: DataCollectionAction) -> DataCollectionState {
        var newState = state

        switch action {
        case let .setProvider(providerID, providerDisplayName):
            newState.providerID = providerID
            newState.providerDisplayName = providerDisplayName
        case .startAuthentication:
            newState.id = UUID()
            newState.authMethod = nil
        case let .setStatus(status):
            newState.status = status
        case let .setAuthMethod(method):
            newState.authMethod = method
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

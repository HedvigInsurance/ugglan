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

public struct DataCollectionInsurance: Equatable, Codable {
    public var providerDisplayName: String
    public var displayName: String
    public var monthlyNetPremium: MonetaryAmount
}

public enum DataCollectionCredential: Equatable, Codable {
    case personalNumber(number: String)
    case phoneNumber(number: String)
}

public struct DataCollectionSession: StateProtocol {
    var providerID: String? = nil
    var providerDisplayName: String? = nil
    var id: UUID
    var status = DataCollectionStatus.none
    var authMethod: DataCollectionAuthMethod? = nil
    var market: Localization.Locale.Market
    var credential: DataCollectionCredential? = nil
    var insurances: [DataCollectionInsurance] = []

    public init() {
        self.market = Localization.Locale.currentLocale.market
        self.id = UUID()
    }
}

public struct DataCollectionState: StateProtocol {
    var sessions: [DataCollectionSession] = []

    func sessionFor(_ id: UUID?) -> DataCollectionSession? {
        guard let id = id else {
            return nil
        }
        
        return sessions.first { session in
            session.id == id
        }
    }

    var allInsurances: [DataCollectionInsurance] {
        sessions.flatMap { session in
            session.insurances
        }
    }

    var allStatuses: [DataCollectionStatus] {
        sessions.map { session in
            session.status
        }
    }

    public init() {}
}

public enum DataCollectionSessionAction: ActionProtocol {
    case didIntroDecide(decision: DataCollectionIntroDecision)
    case confirmResult(result: DataCollectionConfirmationResult)
    case setCredential(credential: DataCollectionCredential)
    case startAuthentication
    case setStatus(status: DataCollectionStatus)
    case setAuthMethod(method: DataCollectionAuthMethod)
    case fetchInfo
    case setInsurances(insurances: [DataCollectionInsurance])
}

public enum DataCollectionAction: ActionProtocol {
    case startSession(id: UUID, providerID: String, providerDisplayName: String)
    case session(id: UUID, action: DataCollectionSessionAction)
}

public final class DataCollectionStore: StateStore<DataCollectionState, DataCollectionAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    func dataCollectionSubscription(for sessionId: UUID) -> FiniteSignal<DataCollectionAction> {
        FiniteSignal { callback in
            let bag = DisposeBag()

            bag += self.client
                .subscribe(subscription: GraphQL.DataCollectionSubscription(reference: sessionId.uuidString))
                .onValue({ data in
                    if let extraInformation = data.dataCollectionStatusV2.extraInformation?.asSwedishBankIdExtraInfo {
                        if let token = extraInformation.autoStartToken {
                            callback(
                                .value(
                                    .session(
                                        id: sessionId,
                                        action: .setAuthMethod(
                                            method: .swedishBankIDAutoStartToken(token: token)
                                        )
                                    )
                                )
                            )
                        }
                    } else if let extraInformation = data.dataCollectionStatusV2.extraInformation?
                        .asNorwegianBankIdExtraInfo
                    {
                        callback(
                            .value(
                                .session(
                                    id: sessionId,
                                    action: .setAuthMethod(
                                        method: .norwegianBankIDWords(
                                            words: extraInformation.norwegianBankIdWords ?? ""
                                        )
                                    )
                                )
                            )
                        )
                    } else {
                        callback(
                            .value(
                                .session(
                                    id: sessionId,
                                    action: .setAuthMethod(
                                        method: .swedishBankIDEphemeral
                                    )
                                )
                            )
                        )
                    }

                    switch data.dataCollectionStatusV2.status {
                    case .running:
                        callback(.value(.session(id: sessionId, action: .setStatus(status: .none))))
                    case .login:
                        callback(.value(.session(id: sessionId, action: .setStatus(status: .login))))
                    case .collecting:
                        callback(.value(.session(id: sessionId, action: .setStatus(status: .collecting))))
                    case .completed, .completedPartial:
                        callback(.value(.session(id: sessionId, action: .setStatus(status: .completed))))
                        callback(.end)
                    case .failed, .completedEmpty, .waitingForAuthentication:
                        callback(.value(.session(id: sessionId, action: .setStatus(status: .failed))))
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
        switch action {
        case let .session(sessionId, sessionAction):

            if case .startAuthentication = sessionAction,
                let session = getState().sessionFor(sessionId)
            {
                cancelEffect(action)
                let market = session.market
                let credential = session.credential
                let reference = session.id.uuidString
                let providerID = session.providerID ?? ""

                return FiniteSignal { callback in
                    let bag = DisposeBag()

                    func startSubscription() {
                        bag += self.dataCollectionSubscription(for: session.id)
                            .atValue { action in
                                callback(.value(action))
                            }
                            .onEnd {
                                callback(.end)
                            }
                    }

                    switch market {
                    case .se:
                        if case let .personalNumber(personalNumber) = credential {
                            bag += self.client
                                .perform(
                                    mutation: GraphQL.DataCollectionSwedenMutation(
                                        reference: reference,
                                        provider: providerID,
                                        personalNumber: personalNumber
                                    )
                                )
                                .map { _ in
                                    DataCollectionAction.session(id: sessionId, action: .setStatus(status: .started))
                                }
                                .onValue { action in
                                    callback(.value(action))
                                    startSubscription()
                                }
                        }
                    case .no:
                        if case let .personalNumber(personalNumber) = credential {
                            self.client
                                .perform(
                                    mutation: GraphQL.DataCollectionNorwayMutation(
                                        reference: reference,
                                        provider: providerID,
                                        personalNumber: personalNumber
                                    )
                                )
                                .map { _ in
                                    DataCollectionAction.session(id: sessionId, action: .setStatus(status: .started))
                                }
                                .onValue { action in
                                    callback(.value(action))
                                    startSubscription()
                                }
                        } else if case let .phoneNumber(phoneNumber) = credential {
                            self.client
                                .perform(
                                    mutation: GraphQL.DataCollectionNorwayPhoneMutation(
                                        reference: reference,
                                        provider: providerID,
                                        phoneNumber: phoneNumber
                                    )
                                )
                                .map { _ in
                                    DataCollectionAction.session(id: sessionId, action: .setStatus(status: .started))
                                }
                                .onValue { action in
                                    callback(.value(action))
                                    startSubscription()
                                }
                        }

                    case .dk, .fr:
                        break
                    }

                    return bag
                }
            } else if case .setStatus(status: .completed) = sessionAction {
                return [
                    .session(id: sessionId, action: .fetchInfo)
                ]
                .emitEachThenEnd
            } else if case .fetchInfo = sessionAction {
                return self.client
                    .fetch(query: GraphQL.DataCollectionInfoQuery(reference: sessionId.uuidString))
                    .map { data in
                        if let insurances = data.externalInsuranceProvider?.dataCollectionV2 {
                            let dataCollectionInsurances = insurances.compactMap { info -> DataCollectionInsurance? in
                                if let personalTravelCollection = info.asPersonTravelInsuranceCollection,
                                    let monthlyNetPremiumFragment = personalTravelCollection.monthlyNetPremium?
                                        .fragments
                                        .monetaryAmountFragment
                                {
                                    return DataCollectionInsurance(
                                        providerDisplayName: getState().sessionFor(sessionId)?.providerDisplayName ?? "",
                                        displayName: personalTravelCollection.insuranceName ?? "",
                                        monthlyNetPremium: MonetaryAmount(fragment: monthlyNetPremiumFragment)
                                    )
                                } else if let houseInsuranceCollection = info.asHouseInsuranceCollection,
                                    let monthlyNetPremiumFragment = houseInsuranceCollection.monthlyNetPremium?
                                        .fragments
                                        .monetaryAmountFragment
                                {
                                    return DataCollectionInsurance(
                                        providerDisplayName: getState().sessionFor(sessionId)?.providerDisplayName ?? "",
                                        displayName: houseInsuranceCollection.insuranceName ?? "",
                                        monthlyNetPremium: MonetaryAmount(fragment: monthlyNetPremiumFragment)
                                    )
                                }

                                return nil
                            }

                            return .session(id: sessionId, action: .setInsurances(insurances: dataCollectionInsurances))
                        }

                        return .session(id: sessionId, action: .setStatus(status: .failed))
                    }
                    .valueThenEndSignal
            }
        default:
            break
        }

        return nil
    }

    override public func reduce(_ state: DataCollectionState, _ action: DataCollectionAction) -> DataCollectionState {
        var newState = state

        switch action {
        case let .session(sessionId, action: sessionAction):
            if var newSession = newState.sessionFor(sessionId) {
                switch sessionAction {
                case let .setCredential(credential):
                    newSession.credential = credential
                case .startAuthentication:
                    newSession.id = UUID()
                    newSession.authMethod = nil
                    newSession.status = .none
                case let .setStatus(status):
                    newSession.status = status
                case let .setAuthMethod(method):
                    newSession.authMethod = method
                case let .setInsurances(insurances):
                    newSession.insurances = insurances
                default:
                    break
                }

                newState.sessions = [
                    newState.sessions.filter({ session in
                        session.id != sessionId
                    }),
                    [
                        newSession
                    ],
                ]
                .flatMap { $0 }
            }

        case let .startSession(id, providerID, providerDisplayName):
            var newSession = DataCollectionSession()
            newSession.id = id
            newSession.providerID = providerID
            newSession.providerDisplayName = providerDisplayName
            newSession.providerID = providerID
            newSession.providerDisplayName = providerDisplayName

            newState.sessions = [newState.sessions, [newSession]].flatMap { $0 }
        }

        return newState
    }
}

extension View {
    func mockProvider() -> some View {
        mockState(DataCollectionStore.self) { state in
            var newState = state

            var newSession = DataCollectionSession()
            newSession.providerID = "Hedvig"
            newSession.providerDisplayName = "Hedvig"

            newState.sessions = [
                newSession
            ]

            return newState
        }
    }
}

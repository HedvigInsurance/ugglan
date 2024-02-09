import Apollo
import Contracts
import EditCoInsured
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ImportantMessage: Codable, Equatable {
    let id: String
    let message: String?
    let link: String?
}

public struct UpcomingRenewal: Codable, Equatable {
    let renewalDate: String?
    let draftCertificateUrl: String?

    public init?(
        upcomingRenewal: OctopusGraphQL.AgreementFragment?
    ) {
        guard let upcomingRenewal, upcomingRenewal.creationCause == .renewal else { return nil }
        self.renewalDate = upcomingRenewal.activeFrom
        self.draftCertificateUrl = upcomingRenewal.certificateUrl
    }
}

enum RenewalType {
    case regular
    case coInsured
}

public struct Contract: Codable, Equatable {
    var upcomingRenewal: UpcomingRenewal?
    var displayName: String

    public init(
        contract: OctopusGraphQL.HomeQuery.Data.CurrentMember.ActiveContract
    ) {
        upcomingRenewal = UpcomingRenewal(
            upcomingRenewal: contract.upcomingChangedAgreement?.fragments.agreementFragment
        )
        displayName = contract.exposureDisplayName
    }
}

public struct MemberStateData: Codable, Equatable {
    public let state: MemberContractState
    public let name: String?

    public init(
        state: MemberContractState,
        name: String?
    ) {
        self.state = state
        self.name = name
    }
}

public struct HomeState: StateProtocol {
    public var memberStateData: MemberStateData = .init(state: .loading, name: nil)
    public var futureStatus: FutureStatus = .none
    public var contracts: [Contract] = []
    public var importantMessages: [ImportantMessage] = []
    public var commonClaims: [CommonClaim] = []
    public var allCommonClaims: [CommonClaim] = []
    public var toolbarOptionTypes: [ToolbarOptionType] = [.chat]
    @Transient(defaultValue: []) var hidenImportantMessages = [String]()
    public var upcomingRenewalContracts: [Contract] {
        return contracts.filter { $0.upcomingRenewal != nil }
    }
    public var showChatNotification = false
    public var hasAtLeastOneClaim = false
    public var hasSentOrRecievedAtLeastOneMessage = false

    public var latestChatTimeStamp = Date()

    public var hasFirstVet: Bool {
        return commonClaims.first(where: { $0.id == "30" || $0.id == "31" || $0.id == "32" }) != nil
    }

    func getImportantMessageToShow() -> [ImportantMessage] {
        return importantMessages.filter { importantMessage in
            !hidenImportantMessages.contains(importantMessage.id)
        }
    }

    func getImportantMessage(with id: String) -> ImportantMessage? {
        return importantMessages.first(where: { $0.id == id })
    }

    public init() {}
}

public enum HomeAction: ActionProtocol {
    case fetchMemberState
    case fetchImportantMessages
    case setImportantMessages(messages: [ImportantMessage])
    case setMemberContractState(state: MemberStateData, contracts: [Contract])
    case setFutureStatus(status: FutureStatus)
    case fetchUpcomingRenewalContracts
    case openDocument(contractURL: URL)
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case startClaim
    case openFreeTextChat(from: ChatTopicType?)
    case openHelpCenter
    case showNewOffer
    case openCommonClaimDetail(commonClaim: CommonClaim, fromOtherServices: Bool)
    case openCoInsured(contractIds: [InsuredPeopleConfig])
    case fetchChatNotifications
    case setChatNotification(hasNew: Bool)
    case setChatNotificationTimeStamp(sentAt: Date)

    case fetchClaims
    case setHasSentOrRecievedAtLeastOneMessage(hasSent: Bool)
    case setHasAtLeastOneClaim(has: Bool)

    case dismissOtherServices
    case hideImportantMessage(id: String)
    case openContractCertificate(url: URL, title: String)

    case openHelpCenterTopicView(commonTopic: CommonTopic)
    case openHelpCenterQuestionView(question: Question)
    case goToQuickAction(CommonClaim)
    case goToURL(url: URL)
    case dismissHelpCenter
}

public enum FutureStatus: Codable, Equatable {
    case activeInFuture(inceptionDate: String)
    case pendingSwitchable
    case pendingNonswitchable
    case none
}

extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    fileprivate var futureStatus: FutureStatus {
        let localDate = Date().localDateString.localDateToDate ?? Date()
        let allActiveInFuture = activeContracts.allSatisfy({ contract in
            return contract.masterInceptionDate.localDateToDate?.daysBetween(start: localDate) ?? 0 > 0
        })

        let externalInsraunceCancellation = pendingContracts.compactMap({ contract in
            contract.externalInsuranceCancellationHandledByHedvig
        })

        if allActiveInFuture && externalInsraunceCancellation.count == 0 {
            return .activeInFuture(inceptionDate: activeContracts.first?.masterInceptionDate ?? "")
        } else if let firstExternal = externalInsraunceCancellation.first {
            return firstExternal ? .pendingSwitchable : .pendingNonswitchable
        }
        return .none
    }
}

public enum HomeLoadingType: LoadingProtocol {
    case fetchCommonClaim
}

public final class HomeStore: LoadingStateStore<HomeState, HomeAction, HomeLoadingType> {
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> HomeState,
        _ action: HomeAction
    ) -> FiniteSignal<HomeAction>? {
        switch action {
        case .fetchImportantMessages:
            return octopus
                .client
                .fetch(query: OctopusGraphQL.ImportantMessagesQuery())
                .map { data in
                    var messages = data.currentMember.importantMessages.compactMap({
                        ImportantMessage(id: $0.id, message: $0.message, link: $0.link)
                    })
                    return .setImportantMessages(messages: messages)
                }
                .valueThenEndSignal
        case .fetchMemberState:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag +=
                    self.octopus
                    .client
                    .fetch(query: OctopusGraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)
                    .onValue { data in
                        let contracts = data.currentMember.activeContracts.map { Contract(contract: $0) }
                        callback(
                            .value(
                                .setMemberContractState(
                                    state: .init(
                                        state: data.currentMember.homeState,
                                        name: data.currentMember.firstName
                                    ),
                                    contracts: contracts
                                )
                            )
                        )
                        callback(.value(.setFutureStatus(status: data.currentMember.futureStatus)))
                    }
                    .onError { [weak self] error in
                        if ApplicationContext.shared.isDemoMode {
                            callback(.value(.setCommonClaims(commonClaims: [])))
                        } else {
                            self?.setError(L10n.General.errorBody, for: .fetchCommonClaim)
                        }
                    }
                return disposeBag
            }
        case .fetchCommonClaims:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.CommonClaimsQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { claimData in
                        let commonClaims = claimData.currentMember.activeContracts
                            .flatMap({ $0.currentAgreement.productVariant.commonClaimDescriptions })
                            .compactMap({ CommonClaim(claim: $0) })
                            .unique()
                        callback(.value(.setCommonClaims(commonClaims: commonClaims)))
                    }
                    .onError { [weak self] error in
                        if ApplicationContext.shared.isDemoMode {
                            callback(.value(.setCommonClaims(commonClaims: [])))
                        } else {
                            self?.setError(L10n.General.errorBody, for: .fetchCommonClaim)
                        }
                    }
                return disposeBag
            }
        case .fetchChatNotifications:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.ChatMessageTimeStampQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { data in
                        if let date = data.chat.messages.first?.sentAt.localDateToIso8601Date {
                            //check if it is auto generated bot message
                            let onlyAutoGeneratedBotMessage =
                                data.chat.messages.count == 1 && date.addingTimeInterval(2) > Date()

                            if onlyAutoGeneratedBotMessage {
                                callback(.value(.setChatNotification(hasNew: false)))
                            } else if self.state.latestChatTimeStamp < date {
                                callback(.value(.setChatNotification(hasNew: true)))
                            } else {
                                callback(.value(.setChatNotification(hasNew: false)))
                            }

                            var hasReceivedMoreThanOneMessage: Bool {
                                if onlyAutoGeneratedBotMessage {
                                    return false
                                } else {
                                    return !data.chat.messages.filter({ $0.sender == .hedvig }).isEmpty
                                }
                            }

                            let hasSentMoreThanOneMessage = !data.chat.messages.filter({ $0.sender == .member }).isEmpty

                            if hasReceivedMoreThanOneMessage || hasSentMoreThanOneMessage {
                                callback(.value(.setHasSentOrRecievedAtLeastOneMessage(hasSent: true)))
                            } else {
                                callback(.value(.setHasSentOrRecievedAtLeastOneMessage(hasSent: false)))
                            }
                        }
                    }
                return disposeBag
            }

        case .fetchClaims:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.ClaimsFileQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue { data in
                        if data.currentMember.claims.count != 0 {
                            callback(.value(.setHasAtLeastOneClaim(has: true)))
                        } else {
                            callback(.value(.setHasAtLeastOneClaim(has: false)))
                        }
                    }
                return disposeBag
            }

        default:
            return nil
        }
    }

    public override func reduce(_ state: HomeState, _ action: HomeAction) -> HomeState {
        var newState = state

        switch action {
        case .setMemberContractState(let memberState, let contracts):
            newState.memberStateData = memberState
            newState.contracts = contracts
        case .setFutureStatus(let status):
            newState.futureStatus = status
        case .setImportantMessages(let messages):
            newState.importantMessages = messages
        case .fetchCommonClaims:
            setLoading(for: .fetchCommonClaim)
        case let .setCommonClaims(commonClaims):
            removeLoading(for: .fetchCommonClaim)
            newState.commonClaims = commonClaims
            setAllCommonClaims(&newState)
        case let .hideImportantMessage(id):
            newState.hidenImportantMessages.append(id)
        case let .setChatNotification(hasNew):
            newState.showChatNotification = hasNew
            setAllCommonClaims(&newState)
        case let .setHasAtLeastOneClaim(has):
            newState.hasAtLeastOneClaim = has
            setAllCommonClaims(&newState)
        case let .setChatNotificationTimeStamp(sentAt):
            newState.latestChatTimeStamp = sentAt
            newState.showChatNotification = false
            setAllCommonClaims(&newState)
        case let .setHasSentOrRecievedAtLeastOneMessage(hasSent):
            newState.hasSentOrRecievedAtLeastOneMessage = hasSent
            setAllCommonClaims(&newState)
        default:
            break
        }

        return newState
    }

    private func setAllCommonClaims(_ state: inout HomeState) {
        var allCommonClaims = [CommonClaim]()

        allCommonClaims.append(.changeBank())

        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let contracts = contractStore.state.activeContracts

        if Dependencies.featureFlags().isEditCoInsuredEnabled
            && !contracts.filter({ $0.showEditCoInsuredInfo }).isEmpty
        {
            allCommonClaims.append(.editCoInsured())
        }

        if Dependencies.featureFlags().isMovingFlowEnabled
            && !contracts.filter({ $0.supportsAddressChange }).isEmpty
        {
            allCommonClaims.append(.moving())
        }
        if Dependencies.featureFlags().isTravelInsuranceEnabled
            && !contracts.filter({ $0.supportsTravelCertificate }).isEmpty
        {
            allCommonClaims.append(.travelInsurance())
        }
        allCommonClaims.append(contentsOf: state.commonClaims)
        state.allCommonClaims = allCommonClaims

        var types: [ToolbarOptionType] = []
        types.append(.newOffer)

        if state.hasFirstVet {
            types.append(.firstVet)
        }

        if state.hasAtLeastOneClaim || state.hasSentOrRecievedAtLeastOneMessage {
            if state.showChatNotification {
                types.append(.chatNotification)
            } else {
                types.append(.chat)
            }
        }

        state.toolbarOptionTypes = types
    }
}

public enum MemberContractState: String, Codable, Equatable {
    case terminated
    case future
    case active
    case loading
}

extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    fileprivate var homeState: MemberContractState {
        if isFuture {
            return .future
        } else if isTerminated {
            return .terminated
        } else {
            return .active
        }
    }

    private var isTerminated: Bool {
        return activeContracts.count == 0 && pendingContracts.count == 0
    }

    private var isFuture: Bool {
        let hasActiveContractsInFuture = activeContracts.allSatisfy { contract in
            return contract.currentAgreement.activeFrom.localDateToDate?.daysBetween(start: Date()) ?? 0 > 0
        }
        return !activeContracts.isEmpty && hasActiveContractsInFuture
    }
}

extension CommonClaim {
    public static func travelInsurance() -> CommonClaim {
        let titleAndBulletPoint = CommonClaim.Layout.TitleAndBulletPoints(
            color: "",
            buttonTitle: L10n.TravelCertificate.getTravelCertificateButton,
            title: "",
            bulletPoints: []
        )
        let emergency = CommonClaim.Layout.Emergency(title: L10n.TravelCertificate.description, color: "")
        let layout = CommonClaim.Layout(titleAndBulletPoint: titleAndBulletPoint, emergency: emergency)
        let commonClaim = CommonClaim(
            id: "travelInsurance",
            icon: nil,
            imageName: "travelCertificate",
            displayTitle: L10n.TravelCertificate.cardTitle,
            layout: layout
        )
        return commonClaim
    }

    public static func moving() -> CommonClaim {
        return CommonClaim(
            id: "moving_flow",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.InsuranceDetails.changeAddressButton,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }

    public static func editCoInsured() -> CommonClaim {
        CommonClaim(
            id: "edit_coinsured",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.hcQuickActionsEditCoinsured,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }

    public static func changeBank() -> CommonClaim {
        CommonClaim(
            id: "change_bank",
            icon: nil,
            imageName: nil,
            displayTitle: L10n.hcQuickActionsChangeBank,
            layout: .init(titleAndBulletPoint: nil, emergency: nil)
        )
    }
}

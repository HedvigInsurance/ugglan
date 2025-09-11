import Chat
import Foundation
import Home
import hCore
import hGraphQL

class HomeClientOctopus: HomeClient {
    @Inject private var octopus: hOctopus
    @Inject private var featureFlags: FeatureFlags

    func getImportantMessages() async throws -> [ImportantMessage] {
        let data =
            try await octopus
            .client
            .fetch(query: OctopusGraphQL.ImportantMessagesQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
        let messages = data.currentMember.importantMessages.map { data in
            let link: ImportantMessage.LinkInfo? = {
                if let linkInfo = data.linkInfo, let url = URL(string: linkInfo.url) {
                    return .init(link: url, text: linkInfo.buttonText)
                }
                return nil
            }()
            return ImportantMessage(id: data.id, message: data.message, linkInfo: link)
        }
        return messages
    }

    func getMemberState() async throws -> MemberState {
        let data =
            try await octopus
            .client
            .fetch(query: OctopusGraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

        let memberId = data.currentMember.id
        let isContactInfoUpdateNeeded = data.currentMember.memberActions?.isContactInfoUpdateNeeded ?? false
        let contracts = data.currentMember.activeContracts.map { HomeContract(contract: $0) }
        let contractState = data.currentMember.homeState
        let futureStatus = data.currentMember.futureStatus

        return .init(
            memberInfo: .init(id: memberId, isContactInfoUpdateNeeded: isContactInfoUpdateNeeded),
            contracts: contracts,
            contractState: contractState,
            futureState: futureStatus
        )
    }

    func getQuickActions() async throws -> [QuickAction] {
        let data = try await octopus.client
            .fetch(
                query: OctopusGraphQL.MemberActionsQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )

        var quickActions = [QuickAction]()
        let actions = data.currentMember.memberActions
        var contractAction = [QuickAction]()

        if actions?.isEditCoInsuredEnabled == true {
            contractAction.append(.editCoInsured)
        }

        if actions?.isChangeTierEnabled == true {
            contractAction.append(.upgradeCoverage)
        }

        if actions?.isCancelInsuranceEnabled == true, featureFlags.isTerminationFlowEnabled {
            contractAction.append(.cancellation)
        }

        if !contractAction.isEmpty {
            quickActions.append(.editInsurance(actions: .init(quickActions: contractAction)))
        }

        if actions?.isMovingEnabled == true, featureFlags.isMovingFlowEnabled {
            quickActions.append(.changeAddress)
        }

        if actions?.isConnectPaymentEnabled == true {
            quickActions.append(.connectPayments)
        }
        if actions?.isTravelCertificateEnabled == true {
            quickActions.append(.travelInsurance)
        }
        if let firstVetSections = actions?.firstVetAction?.sections {
            let firstVetPartners = firstVetSections.compactMap {
                FirstVetPartner(
                    id: $0.title ?? "",
                    buttonTitle: $0.buttonTitle,
                    description: $0.description,
                    url: $0.url,
                    title: $0.title
                )
            }
            quickActions.append(.firstVet(partners: firstVetPartners))
        }

        if let sickAbroadPartners = actions?.sickAbroadAction?.deflectPartners {
            let firstVetPartners = sickAbroadPartners.compactMap {
                SickAbroadPartner(
                    id: $0.id,
                    imageUrl: $0.imageUrl,
                    phoneNumber: $0.phoneNumber,
                    url: $0.url,
                    preferredImageHeight: $0.preferredImageHeight
                )
            }
            quickActions.append(.sickAbroad(partners: firstVetPartners))
        }
        return quickActions
    }

    func getMessagesState() async throws -> MessageState {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ConversationsTimeStampQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )

        var conversationsTimestamps = data.currentMember.conversations.map {
            $0.newestMessage?.sentAt.localDateToIso8601Date
        }
        let hasNewMessages =
            (data.currentMember.conversations.first(where: { $0.unreadMessageCount > 0 })?.unreadMessageCount ?? data
                .currentMember.legacyConversation?
                .unreadMessageCount ?? 0) > 0
        let hasSentOrRecievedAtLeastOneMessage: Bool =
            !data.currentMember.conversations.isEmpty || data.currentMember.legacyConversation?.newestMessage != nil

        if let legacyConversation = data.currentMember.legacyConversation {
            if let date = legacyConversation.newestMessage?.sentAt.localDateToIso8601Date {
                conversationsTimestamps.append(date)
            }
        }
        let maxDate = conversationsTimestamps.compactMap { $0 }.max()

        return .init(
            hasNewMessages: hasNewMessages,
            hasSentOrRecievedAtLeastOneMessage: hasSentOrRecievedAtLeastOneMessage,
            lastMessageTimeStamp: maxDate
        )
    }

    func getFAQ() async throws -> HelpCenterFAQModel {
        let query = OctopusGraphQL.MemberFAQQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return data.asHelpCenterModel
    }
}

extension OctopusGraphQL.MemberFAQQuery.Data {
    fileprivate var asHelpCenterModel: HelpCenterFAQModel {
        let commonQuestions = currentMember.memberFAQ.commonFAQ.compactMap(\.fragments.fAQFragment.asQuestion)
        return .init(
            topics: currentMember.memberFAQ.topics.compactMap(\.asTopic),
            commonQuestions: commonQuestions
        )
    }
}

extension OctopusGraphQL.FAQFragment {
    fileprivate var asQuestion: FAQModel {
        .init(id: id, question: question, answer: answer)
    }
}

extension OctopusGraphQL.MemberFAQQuery.Data.CurrentMember.MemberFAQ.Topic {
    fileprivate var asTopic: FaqTopic {
        .init(
            id: id,
            title: title,
            commonQuestions: commonFAQ.compactMap(\.fragments.fAQFragment.asQuestion),
            allQuestions: otherFAQ.compactMap(\.fragments.fAQFragment.asQuestion)
        )
    }
}

@MainActor
extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    fileprivate var futureStatus: FutureStatus {
        let localDate = Date().localDateString.localDateToDate ?? Date()
        let allActiveInFuture = activeContracts.allSatisfy { contract in
            contract.masterInceptionDate.localDateToDate?.daysBetween(start: localDate) ?? 0 > 0
        }

        let externalInsraunceCancellation = pendingContracts.compactMap { contract in
            contract.externalInsuranceCancellationHandledByHedvig
        }

        if allActiveInFuture, externalInsraunceCancellation.count == 0 {
            return .activeInFuture(inceptionDate: activeContracts.first?.masterInceptionDate ?? "")
        } else if let firstExternal = externalInsraunceCancellation.first {
            return firstExternal ? .pendingSwitchable : .pendingNonswitchable
        }
        return .none
    }
}

extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    @MainActor
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
        activeContracts.count == 0 && pendingContracts.count == 0
    }

    @MainActor
    private var isFuture: Bool {
        let hasActiveContractsInFuture = activeContracts.allSatisfy { contract in
            contract.currentAgreement.activeFrom.localDateToDate ?? Date() > Date()
        }
        return (!activeContracts.isEmpty && hasActiveContractsInFuture)
            || (!pendingContracts.isEmpty && activeContracts.isEmpty)
    }
}

extension HomeContract {
    fileprivate init(
        contract: OctopusGraphQL.HomeQuery.Data.CurrentMember.ActiveContract
    ) {
        self.init(
            upcomingRenewal: UpcomingRenewal(
                upcomingRenewal: contract.upcomingChangedAgreement?.fragments.agreementFragment
            ),
            displayName: contract.exposureDisplayName
        )
    }
}

extension UpcomingRenewal {
    fileprivate init?(
        upcomingRenewal: OctopusGraphQL.AgreementFragment?
    ) {
        guard let upcomingRenewal, upcomingRenewal.creationCause == .renewal else { return nil }
        self.init(renewalDate: upcomingRenewal.activeFrom, draftCertificateUrl: upcomingRenewal.certificateUrl)
    }
}

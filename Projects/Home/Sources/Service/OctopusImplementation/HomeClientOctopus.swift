import Chat
import Foundation
import hCore
import hGraphQL

public class HomeClientOctopus: HomeClient {
    @Inject var octopus: hOctopus
    @Inject var featureFlags: FeatureFlags
    public init() {}

    public func getImportantMessages() async throws -> [ImportantMessage] {
        let data = try await self.octopus
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

    public func getMemberState() async throws -> MemberState {
        let data = try await self.octopus
            .client
            .fetch(query: OctopusGraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

        let memberId = data.currentMember.id
        let contracts = data.currentMember.activeContracts.map { HomeContract(contract: $0) }
        let contractState = data.currentMember.homeState
        let futureStatus = data.currentMember.futureStatus

        return .init(
            id: memberId,
            contracts: contracts,
            contractState: contractState,
            futureState: futureStatus
        )
    }

    public func getQuickActions() async throws -> [QuickAction] {
        let data = try await self.octopus.client
            .fetch(
                query: OctopusGraphQL.MemberActionsQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )

        var quickActions = [QuickAction]()
        let actions = data.currentMember.memberActions
        var contractAction = [QuickAction]()

        if actions?.isEditCoInsuredEnabled == true && featureFlags.isEditCoInsuredEnabled {
            contractAction.append(.editCoInsured)
        }

        if actions?.isChangeTierEnabled == true {
            contractAction.append(.upgradeCoverage)
        }

        if actions?.isCancelInsuranceEnabled == true && featureFlags.isTerminationFlowEnabled {
            contractAction.append(.cancellation)
        }

        if !contractAction.isEmpty {
            quickActions.append(.editInsurance(actions: .init(quickActions: contractAction)))
        }

        if actions?.isMovingEnabled == true && featureFlags.isMovingFlowEnabled {
            quickActions.append(.changeAddress)
        }

        if actions?.isConnectPaymentEnabled == true {
            quickActions.append(.connectPayments)
        }
        if actions?.isTravelCertificateEnabled == true && featureFlags.isTravelInsuranceEnabled {
            quickActions.append(.travelInsurance)
        }
        if let firstVetSections = actions?.firstVetAction?.sections {
            let firstVetPartners = firstVetSections.compactMap({
                FirstVetPartner(
                    id: $0.title ?? "",
                    buttonTitle: $0.buttonTitle,
                    description: $0.description,
                    url: $0.url,
                    title: $0.title
                )
            })
            quickActions.append(.firstVet(partners: firstVetPartners))
        }

        if let sickAbroadPartners = actions?.sickAbroadAction?.partners {
            let firstVetPartners = sickAbroadPartners.compactMap({
                SickAbroadPartner(
                    id: $0.id,
                    imageUrl: $0.imageUrl,
                    phoneNumber: $0.phoneNumber,
                    url: $0.url
                )
            })
            quickActions.append(.sickAbroad(partners: firstVetPartners))
        }
        return quickActions
    }

    public func getMessagesState() async throws -> MessageState {
        let data = try await self.octopus.client.fetch(
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
        let hasSentOrRecievedAtLeastOneMessage: Bool = {
            !data.currentMember.conversations.isEmpty || data.currentMember.legacyConversation?.newestMessage != nil
        }()

        if let legacyConversation = data.currentMember.legacyConversation {
            if let date = legacyConversation.newestMessage?.sentAt.localDateToIso8601Date {
                conversationsTimestamps.append(date)
            }
        }
        let maxDate = conversationsTimestamps.compactMap({ $0 }).max()

        return .init(
            hasNewMessages: hasNewMessages,
            hasSentOrRecievedAtLeastOneMessage: hasSentOrRecievedAtLeastOneMessage,
            lastMessageTimeStamp: maxDate
        )
    }

    public func getFAQ() async throws -> HelpCenterFAQModel {
        let query = OctopusGraphQL.MemberFAQQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return data.asHelpCenterModel
    }
}
extension OctopusGraphQL.MemberFAQQuery.Data {
    var asHelpCenterModel: HelpCenterFAQModel {
        let commonQuestions = currentMember.memberFAQ.commonFAQ.compactMap({ $0.fragments.fAQFragment.asQuestion })
        return .init(
            topics: currentMember.memberFAQ.topics.compactMap({ $0.asTopic }),
            commonQuestions: commonQuestions
        )
    }
}
extension OctopusGraphQL.FAQFragment {
    var asQuestion: FAQModel {
        .init(id: id, question: question, answer: answer)
    }
}

extension OctopusGraphQL.MemberFAQQuery.Data.CurrentMember.MemberFAQ.Topic {
    var asTopic: FaqTopic {
        .init(
            id: id,
            title: title,
            commonQuestions: commonFAQ.compactMap({ $0.fragments.fAQFragment.asQuestion }),
            allQuestions: otherFAQ.compactMap({ $0.fragments.fAQFragment.asQuestion })
        )
    }
}

@MainActor
extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    var futureStatus: FutureStatus {
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

extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    @MainActor
    var homeState: MemberContractState {
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

    @MainActor
    private var isFuture: Bool {
        let hasActiveContractsInFuture = activeContracts.allSatisfy { contract in
            return contract.currentAgreement.activeFrom.localDateToDate ?? Date() > Date()
        }
        return (!activeContracts.isEmpty && hasActiveContractsInFuture) || !pendingContracts.isEmpty
    }
}

extension HomeContract {
    public init(
        contract: OctopusGraphQL.HomeQuery.Data.CurrentMember.ActiveContract
    ) {
        upcomingRenewal = UpcomingRenewal(
            upcomingRenewal: contract.upcomingChangedAgreement?.fragments.agreementFragment
        )
        displayName = contract.exposureDisplayName
    }
}

extension UpcomingRenewal {
    public init?(
        upcomingRenewal: OctopusGraphQL.AgreementFragment?
    ) {
        guard let upcomingRenewal, upcomingRenewal.creationCause == .renewal else { return nil }
        self.init(renewalDate: upcomingRenewal.activeFrom, draftCertificateUrl: upcomingRenewal.certificateUrl)
    }
}

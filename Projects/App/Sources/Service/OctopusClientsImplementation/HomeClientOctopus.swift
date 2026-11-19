import Chat
import Foundation
import Home
import SubmitClaimChat
import hCore
import hGraphQL

class HomeClientOctopus: HomeClient {
    @Inject private var octopus: hOctopus

    func getImportantMessages() async throws -> [ImportantMessage] {
        try await fetchHome().asImportantMessages
    }

    func getMemberState() async throws -> MemberState {
        try await fetchHome().asMemberState
    }

    func getQuickActions() async throws -> [QuickAction] {
        try await fetchHome().asQuickActions
    }

    func getHomeData() async throws -> HomeData {
        let member = try await fetchHome()
        return .init(
            memberState: member.asMemberState,
            importantMessages: member.asImportantMessages,
            quickActions: member.asQuickActions
        )
    }

    /// Member state, important messages and quick actions all come from the same `HomeQuery`.
    private func fetchHome() async throws -> OctopusGraphQL.HomeQuery.Data.CurrentMember {
        try await octopus.client.fetch(query: OctopusGraphQL.HomeQuery()).currentMember
    }

    func getMessagesState() async throws -> MessageState {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ConversationsTimeStampQuery()
        )

        var conversationsTimestamps = data.currentMember.conversations.map {
            $0.newestMessage?.sentAt.localDateToIso8601Date
        }
        let hasNewMessages =
            (data.currentMember.conversations.first(where: { $0.unreadMessageCount > 0 })?.unreadMessageCount ?? data
                .currentMember.legacyConversation?
                .unreadMessageCount ?? 0) > 0

        if let legacyConversation = data.currentMember.legacyConversation {
            if let date = legacyConversation.newestMessage?.sentAt.localDateToIso8601Date {
                conversationsTimestamps.append(date)
            }
        }
        let maxDate = conversationsTimestamps.compactMap { $0 }.max()

        return .init(
            hasNewMessages: hasNewMessages,
            lastMessageTimeStamp: maxDate
        )
    }

    func getOngoingQuotes() async throws -> [OngoingQuote] {
        let data = try await octopus.client
            .fetch(query: OctopusGraphQL.OngoingShopSessionsQuery())

        return data.currentMember.ongoingShopSessions.compactMap { session in
            guard let resumeUrl = URL(string: session.display.resumeUrl) else { return nil }
            return OngoingQuote(
                id: session.id,
                title: session.display.title,
                subtitle: session.display.subtitle,
                monthlyNet: .init(optionalFragment: session.display.monthlyNet?.fragments.moneyFragment),
                resumeUrl: resumeUrl,
                pillowImageUrl: URL(string: session.display.pillowImage?.fragments.storyblokImageAssetFragment.src)
            )
        }
    }

    func getFAQ() async throws -> HelpCenterFAQModel {
        let query = OctopusGraphQL.MemberFAQQuery()
        let data = try await octopus.client.fetch(query: query)
        return data.asHelpCenterModel
    }
}

@MainActor
extension OctopusGraphQL.HomeQuery.Data.CurrentMember {
    fileprivate var asMemberState: MemberState {
        .init(
            memberInfo: .init(
                id: id,
                firstName: firstName,
                isContactInfoUpdateNeeded: memberActions?.isContactInfoUpdateNeeded ?? false
            ),
            contracts: activeContracts.map { HomeContract(contract: $0) },
            contractState: homeState,
            futureState: futureStatus
        )
    }

    fileprivate var asImportantMessages: [Home.ImportantMessage] {
        let messages = importantMessages.map { data in
            let link: Home.ImportantMessage.LinkInfo? = {
                if let linkInfo = data.linkInfo, let url = URL(string: linkInfo.url) {
                    return .init(link: url, text: linkInfo.buttonText)
                }
                return nil
            }()
            return Home.ImportantMessage(id: data.id, message: data.message, linkInfo: link)
        }
        return messages
    }

    fileprivate var asQuickActions: [QuickAction] {
        guard let actions = memberActions else { return [] }

        var quickActions = [QuickAction]()
        var contractAction = [QuickAction]()

        if actions.isEditCoInsuredEnabled {
            contractAction.append(.editCoInsured)
        }

        if actions.isEditCoOwnersEnabled {
            contractAction.append(.editCoOwners)
        }

        if actions.isChangeTierEnabled {
            contractAction.append(.upgradeCoverage)
        }

        if actions.isCancelInsuranceEnabled {
            contractAction.append(.cancellation)
        }

        if !contractAction.isEmpty {
            quickActions.append(.editInsurance(actions: .init(quickActions: contractAction)))
        }

        if actions.isMovingEnabled {
            quickActions.append(.changeAddress)
        }

        if actions.isConnectPaymentEnabled {
            quickActions.append(.connectPayments)
        }
        if actions.isTravelCertificateEnabled == true {
            quickActions.append(.travelInsurance)
        }
        if let firstVetSections = actions.firstVetAction?.sections {
            let firstVetPartners = firstVetSections.compactMap {
                FirstVetPartner(
                    id: $0.title ?? "",
                    description: $0.description,
                    url: $0.url,
                    title: $0.title
                )
            }
            quickActions.append(.firstVet(partners: firstVetPartners))
        }

        if let sickAbroadDeflect = actions.sickAbroadDeflect {
            let deflection = Deflection(
                title: sickAbroadDeflect.title,
                content: .init(
                    title: sickAbroadDeflect.content.title,
                    description: sickAbroadDeflect.content.description
                ),
                partners: sickAbroadDeflect.partners.map {
                    .init(fragment: $0.fragments.claimIntentOutcomeDeflectionPartnerFragment)
                },
                infoText: sickAbroadDeflect.infoText,
                warningText: sickAbroadDeflect.warningText,
                questions: sickAbroadDeflect.faq.map {
                    .init(question: $0.title, answer: $0.description)
                },
                linkOnlyPartners: sickAbroadDeflect.simplePartners.map {
                    .init(url: $0.url, buttonText: $0.urlButtonTitle)
                },
                buttonTitle: sickAbroadDeflect.buttonTitle
            )
            quickActions.append(.sickAbroad(deflection: deflection))
        }
        return quickActions
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

import Foundation
import hCore
import hGraphQL

public class HomeServiceOctopus: HomeService {
    @Inject var octopus: hOctopus
    @Inject var featureFlags: FeatureFlags
    public init() {}

    public func getImportantMessages() async throws -> [ImportantMessage] {
        octopus
            .client
            .fetch(query: OctopusGraphQL.ImportantMessagesQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            .map { data in
                return data.currentMember.importantMessages.compactMap({
                    ImportantMessage(id: $0.id, message: $0.message, link: $0.link)
                })
            }
        return []
    }

    public func getMemberState() async throws -> MemberState {
        let data = try await self.octopus
            .client
            .fetch(query: OctopusGraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheCompletely)

        let contracts = data.currentMember.activeContracts.map { Contract(contract: $0) }
        let contractState = data.currentMember.homeState
        let futureStatus = data.currentMember.futureStatus

        return .init(
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
        if actions?.isMovingEnabled == true && featureFlags.isMovingFlowEnabled {
            quickActions.append(.changeAddress)
        }
        if actions?.isConnectPaymentEnabled == true {
            quickActions.append(.connectPayments)
        }
        if actions?.isEditCoInsuredEnabled == true && featureFlags.isEditCoInsuredEnabled {
            quickActions.append(.editCoInsured)
        }
        if actions?.isCancelInsuranceEnabled == true && featureFlags.isTerminationFlowEnabled {
            quickActions.append(.cancellation)
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

    public func getLastMessagesDates() async throws -> [Date] {
        let data = try await self.octopus.client
            .fetch(
                query: OctopusGraphQL.ChatMessageTimeStampQuery(until: GraphQLNullable.null),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
        return data.chat.messages.compactMap({ $0.sentAt.localDateToIso8601Date })
    }

    public func getNumberOfClaims() async throws -> Int {
        let data = try await self.octopus.client
            .fetch(
                query: OctopusGraphQL.ClaimsFileQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
        return data.currentMember.claims.count
    }
}

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

    private var isFuture: Bool {
        let hasActiveContractsInFuture = activeContracts.allSatisfy { contract in
            return contract.currentAgreement.activeFrom.localDateToDate?.daysBetween(start: Date()) ?? 0 > 0
        }
        return !activeContracts.isEmpty && hasActiveContractsInFuture
    }
}

extension Contract {
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

import EditCoInsuredShared
import Foundation
import Presentation
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

public indirect enum ContractFilter: Equatable, Hashable {
    var displaysActiveContracts: Bool {
        switch self {
        case .terminated: return false
        case .active: return true
        case .none: return false
        }
    }

    var displaysTerminatedContracts: Bool {
        switch self {
        case .terminated: return true
        case .active: return false
        case .none: return false
        }
    }

    var emptyFilter: ContractFilter {
        switch self {
        case let .terminated(ifEmpty): return ifEmpty
        case let .active(ifEmpty): return ifEmpty
        case .none: return .none
        }
    }

    case terminated(ifEmpty: ContractFilter)
    case active(ifEmpty: ContractFilter)
    case none
}

public struct Contracts {
    @PresentableStore var store: ContractStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let showTerminated: Bool
    public init(
        showTerminated: Bool
    ) {
        self.showTerminated = showTerminated
    }
}

extension Contracts: View {
    func fetch() {
        store.send(.fetchContracts)
    }

    public var body: some View {
        hForm {
            ContractTable(showTerminated: showTerminated)
                .padding(.top, 8)
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hBackgroundColor.primary))
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
        .onPullToRefresh {
            await store.sendAsync(.fetch)
        }
        .hFormAttachToBottom {
            if showTerminated {
                hSection {
                    InfoCard(text: L10n.InsurancesTab.cancelledInsurancesNote, type: .info)
                }
                .sectionContainerStyle(.transparent)
                .padding(.vertical, 16)
            }
        }
    }
}

public enum ContractsResult {
    case movingFlow
    case openFreeTextChat
    case openCrossSellingWebUrl(url: URL)
    case startNewTermination(type: TerminationNavigationAction)
    case handleCoInsured(config: InsuredPeopleConfig, fromInfoCard: Bool)
    case openMissingCoInsuredAlert(config: InsuredPeopleConfig)
}

extension Contracts {
    public static func journey<ResultJourney: JourneyPresentation>(
        showTerminated: Bool = false,
        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney,
        openDetails: Bool = true
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: Contracts(showTerminated: showTerminated)
        ) { action in
            if case let .openDetail(contractId, title) = action, openDetails {
                ContractDetail(id: contractId, title: title).journey(resultJourney: resultJourney)
            } else if case .openTerminatedContracts = action {
                Self.journey(
                    showTerminated: true,
                    resultJourney: resultJourney,
                    openDetails: false
                )
            } else if case .openContractDetailErrorScreen = action {
                ContractDetail(id: "", title: "").contractDetailErrorJourney
            } else if case let .openCrossSellingWebUrl(url) = action {
                resultJourney(.openCrossSellingWebUrl(url: url))
            } else if case .goToFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            } else if case .goToMovingFlow = action {
                resultJourney(.movingFlow)
            } else if case let .coInsuredNavigationAction(action: .openEditCoInsured(config, fromInfoCard)) = action {
                resultJourney(.handleCoInsured(config: config, fromInfoCard: fromInfoCard))
            } else if case let .coInsuredNavigationAction(.openMissingCoInsuredAlert(config)) = action {
                resultJourney(.openMissingCoInsuredAlert(config: config))
            } else if case let .startTermination(navigationAction) = action {
                resultJourney(.startNewTermination(type: navigationAction))
            } else if case let .contractDetailNavigationAction(action: .insurableLimit(limit)) = action {
                InfoView(
                    title: L10n.contractCoverageMoreInfo,
                    description: limit.description,
                    onDismiss: {
                        let store: ContractStore = globalPresentableStoreContainer.get()
                        store.send(.dismissContractDetailNavigation)
                    }
                )
                .journey
                .onAction(ContractStore.self) { action, presenter in
                    if case .dismissContractDetailNavigation = action {
                        presenter.bag.dispose()
                    }
                }
            } else if case let .contractEditInfo(id) = action {
                HostingJourney(
                    ContractStore.self,
                    rootView: EditContract(id: id),
                    style: .detented(.scrollViewContentSize),
                    options: [.largeNavigationBar, .blurredBackground]
                ) { action in
                    if case .dismissEditInfo = action {
                        DismissJourney()
                    }
                }
                .configureTitle(L10n.contractChangeInformationTitle)
            }
        }
        .configureTitle(
            showTerminated
                ? L10n.InsurancesTab.cancelledInsurancesTitle : L10n.InsurancesTab.yourInsurances
        )
        .configureContractsTabBarItem
    }
}

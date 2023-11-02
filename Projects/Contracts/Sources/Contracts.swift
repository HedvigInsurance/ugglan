import Flow
import Foundation
import Introspect
import Presentation
import SwiftUI
import TerminateContracts
import UIKit
import hAnalytics
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
    let disposeBag = DisposeBag()
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
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
        .introspectScrollView { scrollView in
            let refreshControl = UIRefreshControl()
            disposeBag.dispose()
            scrollView.refreshControl = refreshControl
            disposeBag += refreshControl.store(
                store,
                send: {
                    ContractAction.fetch
                },
                endOn: .fetchCompleted
            )

        }
        .hFormAttachToBottom {
            if showTerminated {
                InfoCard(text: L10n.InsurancesTab.cancelledInsurancesNote, type: .info)
                    .padding(16)
            }
        }
    }
}

public enum ContractsResult {
    case movingFlow
    case openFreeTextChat
    case openCrossSellingWebUrl(url: URL)
    case startNewTermination(type: TerminationNavigationAction)
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
            } else if case let .openCrossSellingWebUrl(url) = action {
                resultJourney(.openCrossSellingWebUrl(url: url))
            } else if case .goToFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            } else if case .goToMovingFlow = action {
                resultJourney(.movingFlow)
            } else if case let .openEditCoInsured(contractId, fromInfoCard) = action {
                let store: ContractStore = globalPresentableStoreContainer.get()
                if let canChangeCoInsured = store.state.contractForId(contractId)?.canChangeCoInsured,
                    canChangeCoInsured
                {
                    if let a = store.state.activeContracts.first(where: {
                        $0.coInsured.contains(CoInsuredModel(firstName: nil, lastName: nil, SSN: nil))
                    }) {
                        if fromInfoCard {
                            EditCoInsuredJourney.openNewInsuredPeopleScreen(id: contractId)
                        } else {
                            EditCoInsuredJourney.openRemoveCoInsuredScreen(id: contractId)
                        }
                    } else {
                        EditCoInsuredJourney.openInsuredPeopleScreen(id: contractId)
                    }
                } else {
                    EditCoInsuredJourney.openGenericErrorScreen()
                }
            } else if case let .coInsuredNavigationAction(.openMissingCoInsuredAlert(contractId)) = action {
                EditCoInsuredJourney.openMissingCoInsuredAlert(contractId: contractId)
            } else if case let .startTermination(navigationAction) = action {
                resultJourney(.startNewTermination(type: navigationAction))
            } else if case let .contractDetailNavigationAction(action: .insurableLimit(limit)) = action {
                InfoView(
                    title: L10n.contractCoverageMoreInfo,
                    description: limit.description,
                    onDismiss: {
                        let store: ContractStore = globalPresentableStoreContainer.get()
                        store.send(.dismisscontractDetailNavigation)
                    }
                )
                .journey
                .onAction(ContractStore.self) { action, presenter in
                    if case .dismisscontractDetailNavigation = action {
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

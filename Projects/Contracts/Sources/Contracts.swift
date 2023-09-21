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

extension ContractFilter {
    func nonemptyFilter(state: ContractState) -> ContractFilter {
        switch self {
        case .active:
            let activeContracts =
            state
                .contractBundles
                .flatMap { $0.contracts }
            return activeContracts.isEmpty ? self.emptyFilter : self
        case .terminated:
            let terminatedContracts =
            state.contracts
                .filter { contract in
                    contract.currentAgreement?.status == .terminated
                }
            return terminatedContracts.isEmpty ? self.emptyFilter : self
        case .none: return self
        }
    }
}

public struct Contracts {
    @PresentableStore var store: ContractStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let filter: ContractFilter
    let disposeBag = DisposeBag()
    public init(
        filter: ContractFilter
    ) {
        self.filter = filter
    }
}

extension Contracts: View {
    func fetch() {
        store.send(.fetchContracts)
        store.send(.fetchContractBundles)
    }
    
    public var body: some View {
        hForm {
            ContractTable(filter: filter)
                .padding(.top, 8)
        }
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .insurances))
        .introspectScrollView { scrollView in
            let refreshControl = UIRefreshControl()
            disposeBag.dispose()
            scrollView.refreshControl = refreshControl
            disposeBag += refreshControl.store(
                store,
                send: {
                    ContractAction.fetch
                },
                endOn: .fetchContractBundlesDone,
                .fetchContractsDone
            )
            
        }
        .hFormAttachToBottom {
            if self.filter.displaysTerminatedContracts {
                InfoCard(text: L10n.InsurancesTab.cancelledInsurancesNote, type: .info)
                    .padding(16)
            }
        }
    }
}

public enum ContractsResult {
    case movingFlow
    case openFreeTextChat
    case openCrossSellingDetail(crossSell: CrossSell)
    case openCrossSellingWebUrl(url: URL)
    case startNewTermination(type: TerminationNavigationAction)
}

extension Contracts {
    public static func journey<ResultJourney: JourneyPresentation>(
        filter: ContractFilter = .active(ifEmpty: .terminated(ifEmpty: .none)),
        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney,
        openDetails: Bool = true
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: Contracts(filter: filter)
        ) { action in
            if case let .openDetail(contractId, title) = action, openDetails {
                ContractDetail(id: contractId, title: title).journey(resultJourney: resultJourney)
            } else if case .openTerminatedContracts = action {
                Self.journey(
                    filter: .terminated(ifEmpty: .none),
                    resultJourney: resultJourney,
                    openDetails: false
                )
            } else if case let .openCrossSellingDetail(crossSell) = action {
                resultJourney(.openCrossSellingDetail(crossSell: crossSell))
            } else if case let .openCrossSellingWebUrl(url) = action {
                resultJourney(.openCrossSellingWebUrl(url: url))
            } else if case .goToFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            } else if case .goToMovingFlow = action {
                resultJourney(.movingFlow)
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
        .onPresent({
            let store: ContractStore = globalPresentableStoreContainer.get()
            store.send(.resetSignedCrossSells)
        })
        .configureTitle(
            filter.displaysActiveContracts
            ? L10n.InsurancesTab.yourInsurances : L10n.InsurancesTab.cancelledInsurancesTitle
        )
        .configureContractsTabBarItem
    }
}

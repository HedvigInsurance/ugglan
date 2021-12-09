import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public indirect enum ContractFilter {
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
    let filter: ContractFilter

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
        }
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
    }
}

public enum ContractsResult {
    case movingFlow
    case openFreeTextChat
    case openCrossSellingDetail(crossSell: CrossSell)
    case openCrossSellingEmbark(name: String)
}

extension Contracts {
    public static func journey<ResultJourney: JourneyPresentation>(
        filter: ContractFilter = .active(ifEmpty: .terminated(ifEmpty: .none)),
        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney,
        openDetails: Bool = true
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: Contracts(filter: filter),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(filter.displaysActiveContracts ? .always : .never),
            ]
        ) { action in
            if case let .openDetail(contractId) = action, openDetails {
                ContractDetail(id: contractId).journey()
            } else if case .openTerminatedContracts = action {
                Self.journey(
                    filter: .terminated(ifEmpty: .none),
                    resultJourney: resultJourney,
                    openDetails: false
                )
            } else if case let .openCrossSellingDetail(crossSell) = action {
                resultJourney(.openCrossSellingDetail(crossSell: crossSell))
            } else if case let .openCrossSellingEmbark(name) = action {
                resultJourney(.openCrossSellingEmbark(name: name))
            } else if case .goToFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            } else if case .goToMovingFlow = action {
                resultJourney(.movingFlow)
            }
        }
        .onPresent({
            let store: ContractStore = globalPresentableStoreContainer.get()
            store.send(.resetSignedCrossSells)
        })
        .addConfiguration({ presenter in
            if let navigationController = presenter.viewController as? UINavigationController {
                navigationController.isHeroEnabled = true
                navigationController.hero.navigationAnimationType = .fade
            }

            if filter.displaysActiveContracts {
                presenter.matter.installChatButton()
            }
        })
        .configureTitle(filter.displaysActiveContracts ? L10n.InsurancesTab.title : "")
        .configureContractsTabBarItem
    }
}

import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import SwiftUI

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
    let pollTimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    let filter: ContractFilter
    
    public init(
        filter: ContractFilter
    ) {
        self.filter = filter
    }
}

public enum ContractsResult {
    case movingFlow
    case openFreeTextChat
    case openCrossSellingEmbark(name: String)
}

extension Contracts: View {
    func fetch() {
        store.send(.fetchContracts)
        store.send(.fetchContractBundles)
        store.send(.fetchUpcomingAgreement)
    }
    
    public var body: some View {
        hForm {
            ContractTable(filter: filter)
        }.onReceive(pollTimer) { _ in
            fetch()
        }.onAppear {
            fetch()
        }
    }
}

extension Contracts {
    public static func journey(filter: ContractFilter = .active(ifEmpty: .terminated(ifEmpty: .none))) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: Contracts(filter: filter),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(filter.displaysActiveContracts ? .always : .never)
            ]
        ) { action in
            if case let .openDetail(contract) = action {
                Journey(
                    ContractDetail(
                        contractRow: ContractRow(contract: contract)
                    ),
                    options: [.largeTitleDisplayMode(.never)]
                )
            } else if case .openTerminatedContracts = action {
                Self.journey(filter: .terminated(ifEmpty: .none))
            }
        }
        .addConfiguration({ presenter in
            if let navigationController = presenter.viewController as? UINavigationController {
                navigationController.isHeroEnabled = true
                navigationController.hero.navigationAnimationType = .fade
            }
        })
        .configureTitle(filter.displaysActiveContracts ? L10n.InsurancesTab.title : "")
        .configureContractsTabBarItem
    }
}

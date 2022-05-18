import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct Contracts {
    @PresentableStore var store: ContractStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @State
    var navigationController: UINavigationController?
    
    public init() {}
}

extension Contracts: View {
    func fetch() {
        store.send(.fetchContracts)
        store.send(.fetchContractBundles)
    }

    public var body: some View {
        hForm {
            ContractTable()
        }
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .insurances))
        .navigationBarTitle(L10n.InsurancesTab.title)
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
        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney,
        openDetails: Bool = true
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: Contracts(),
            options: [
                .defaults,
                .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always),
            ]
        ) { action in
            if case let .openDetail(contractId) = action, openDetails {
                ContractDetail(id: contractId).journey()
            } else if case .openTerminatedContracts = action {
                TerminatedContractsTable.journey()
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
            
            presenter.matter.installChatButton()
        })
        .configureContractsTabBarItem
    }
}

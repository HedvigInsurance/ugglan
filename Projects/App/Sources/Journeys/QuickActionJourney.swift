import Claims
import Contracts
import EditCoInsuredShared
import Flow
import Foundation
import Home
import Payment
import Presentation
import Profile
import SwiftUI
import hCore

extension AppJourney {
    @JourneyBuilder
    static func configureQuickAction(quickAction: QuickAction) -> some JourneyPresentation {
        switch quickAction {
        case .connectPayments:
            if let url = DeepLink.getUrl(from: .directDebit) {
                configureURL(url: url)
            }
        case .changeAddress:
            if let url = DeepLink.getUrl(from: .moveContract) {
                configureURL(url: url)
            }
        case .editCoInsured:
            let contractStore: ContractStore = globalPresentableStoreContainer.get()

            let contractsSupportingCoInsured = contractStore.state.activeContracts.filter({ $0.showEditCoInsuredInfo })
                .compactMap({
                    InsuredPeopleConfig(contract: $0, fromInfoCard: false)
                })

            DismissJourney()
        //            if !contractsSupportingCoInsured.isEmpty {
        //                openOnTop(
        //                    vc: AppJourney.editCoInsured(configs: contractsSupportingCoInsured)
        //                )
        //            }
        case .travelInsurance:
            if let url = DeepLink.getUrl(from: .travelCertificate) {
                configureURL(url: url)
            }
        case .cancellation:
            if let url = DeepLink.getUrl(from: .terminateContract) {
                configureURL(url: url)
            }
        case let .firstVet(partners):
            //            let vc = FirstVetView.journey(partners: partners)
            //                .withJourneyDismissButton
            //                .configureTitle(quickAction.displayTitle)

            //            openOnTop(
            //                vc: vc
            //            )
            DismissJourney()
        case .sickAbroad:
            //            openOnTop(
            //                vc: SubmitClaimDeflectScreen.journey
            //            )
            DismissJourney()
        }
    }

    @JourneyBuilder
    static func configureURL(url: URL) -> some JourneyPresentation {
        if let deepLink = DeepLink.getType(from: url), url.absoluteString.isDeepLink {
            DismissJourney()
                .onPresent {
                    if DeepLink.getType(from: url)?.tabURL ?? false {
                        let store: HomeStore = globalPresentableStoreContainer.get()
                        store.send(.dismissHelpCenter)
                    }
                    if let vc = UIApplication.shared.getTopViewController() {
                        UIApplication.shared.appDelegate.handleDeepLink(url, fromVC: vc)
                    }
                }
        } else {
            AppJourney.webRedirect(url: url)
        }
    }

    @JourneyBuilder
    static func openOnTop(vc: some JourneyPresentation) -> some JourneyPresentation {
        let deepLinkDisposeBag = UIApplication.shared.appDelegate.deepLinkDisposeBag
        DismissJourney()
            .onPresent {
                if let fromVc = UIApplication.shared.getTopViewController() {
                    deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                        .onValue { _ in
                            let disposeBag = DisposeBag()
                            disposeBag += fromVc.present(vc)
                        }
                }
            }
    }
}

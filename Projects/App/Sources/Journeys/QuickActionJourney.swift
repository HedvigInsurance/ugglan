import Claims
import Contracts
import EditCoInsured
import Flow
import Foundation
import Home
import Payment
import Presentation
import Profile
import UIKit
import hCore

extension AppJourney {
    @JourneyBuilder
    static func configureQuickAction(commonClaim: CommonClaim) -> some JourneyPresentation {
        switch commonClaim {
        case .changeBank():
            if let url = DeepLink.getUrl(from: .directDebit) {
                configureURL(url: url)
            }
        case .moving():
            if let url = DeepLink.getUrl(from: .moveContract) {
                configureURL(url: url)
            }
        case .editCoInsured():
            let contractStore: ContractStore = globalPresentableStoreContainer.get()

            let contractsSupportingCoInsured = contractStore.state.activeContracts.filter({ $0.showEditCoInsuredInfo })
                .compactMap({
                    InsuredPeopleConfig(contract: $0)
                })

            if !contractsSupportingCoInsured.isEmpty {
                openOnTop(
                    vc: AppJourney.editCoInsured(configs: contractsSupportingCoInsured)
                )
            }
        case .travelInsurance():
            if let url = DeepLink.getUrl(from: .travelCertificate) {
                configureURL(url: url)
            }
        default:
            if commonClaim.layout.titleAndBulletPoint == nil {
                openOnTop(
                    vc: SubmitClaimEmergencyScreen.journey
                )
            } else {
                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                let vc = CommonClaimDetail.journey(claim: commonClaim)
                    .withJourneyDismissButton
                    .configureTitle(commonClaim.displayTitle)

                openOnTop(
                    vc: vc
                )
            }
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

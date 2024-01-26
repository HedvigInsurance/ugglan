import Claims
import Contracts
import EditCoInsured
import Foundation
import Home
import Payment
import Presentation
import TravelCertificate
import UIKit
import hCore

extension AppJourney {
    @JourneyBuilder
    static func configureQuickAction(commonClaim: CommonClaim) -> some JourneyPresentation {
        switch commonClaim {
        case .changeBank():
            PaymentSetup(setupType: .initial).journeyThenDismiss
        case .moving():
            AppJourney.movingFlow()
        case .editCoInsured():
            let contractStore: ContractStore = globalPresentableStoreContainer.get()

            let contractsSupportingCoInsured = contractStore.state.activeContracts.filter({ $0.showEditCoInsuredInfo })
                .compactMap({
                    InsuredPeopleConfig(contract: $0)
                })

            if !contractsSupportingCoInsured.isEmpty {
                AppJourney.editCoInsured(configs: contractsSupportingCoInsured)
            }
        case .travelInsurance():
            TravelInsuranceFlowJourney.start()
        default:
            if commonClaim.layout.titleAndBulletPoint == nil {
                SubmitClaimEmergencyScreen.journey
            } else {
                CommonClaimDetail.journey(claim: commonClaim)
                    .withJourneyDismissButton
                    .configureTitle(commonClaim.displayTitle)
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
}

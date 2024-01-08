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
    static func configureQuickAction(quickAction: QuickAction) -> some JourneyPresentation {
        switch quickAction {
        case .changeBank:
            PaymentSetup(setupType: .initial).journeyThenDismiss
        case .updateAddress:
            AppJourney.movingFlow()
        case .editCoInsured:
            let contractStore: ContractStore = globalPresentableStoreContainer.get()

            let contractsSupportingCoInsured = contractStore.state.activeContracts.filter({ $0.showEditCoInsuredInfo })
                .compactMap({
                    InsuredPeopleConfig(contract: $0)
                })

            if !contractsSupportingCoInsured.isEmpty {
                AppJourney.editCoInsured(configs: contractsSupportingCoInsured)
            }
        case .travelCertificate:
            TravelInsuranceFlowJourney.start {
                AppJourney.freeTextChat()
            }
        }
    }

    @JourneyBuilder
    static func configureURL(url: URL) -> some JourneyPresentation {
        if let deepLink = DeepLink.getType(from: url) {
            DismissJourney()
                .onPresent {
                    if let vc = UIApplication.shared.getTopViewController() {
                        UIApplication.shared.appDelegate.handleDeepLink(url, fromVC: vc)
                    }
                }
        } else {
            AppJourney.webRedirect(url: url)
        }
    }
}

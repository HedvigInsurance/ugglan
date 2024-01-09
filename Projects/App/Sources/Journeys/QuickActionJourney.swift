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
        let urlPath = URLComponents(url: url, resolvingAgainstBaseURL: false)?.path
        let urlIsDeepLink = urlPath?.filter({ $0 == "/" }).count == 1

        if let deepLink = DeepLink.getType(from: url), urlIsDeepLink {
            DismissJourney()
                .onPresent {
                    if isTabURL(url: url) {
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

public enum TabURL {
    case insurances
    case home
    case forever
}

public func getType(attribute: String) -> TabURL? {
    if attribute == "insurances" {
        return .insurances
    } else if attribute == "forever" {
        return .forever
    } else if attribute == "home" {
        return .home
    }
    return nil
}

func isTabURL(url: URL) -> Bool {
    let urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
    guard urlComponent?.host == "hedvig.page.link" || urlComponent?.host == "hedvigtest.page.link" else {
        return false
    }

    if let urlPath = urlComponent?.path.replacingOccurrences(of: "/", with: "") {
        if let isTabType = getType(attribute: urlPath) {
            return true
        }
    }
    return false
}

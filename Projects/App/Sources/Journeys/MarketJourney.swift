import Foundation
import Market
import Presentation
import hCore

extension AppJourney {
    static var marketPicker: some JourneyPresentation {
//        Journey(MarketPicker()) { _ in
//            Journey(Marketing()) { marketingResult in
//                switch marketingResult {
//                case .onboard:
//                    AppJourney.onboarding()
//                case .login:
//                    AppJourney.login
//                }
//            }
//        }
        
        HostingJourney(
            MarketStore.self,
            rootView: MarketPickerView()
        ) { action in
            if case .openMarketing = action {
                Journey(
                    Marketing(),
                    options: [.replaceDetail]
                ) { marketingResult in
                    switch marketingResult {
                    case .onboard:
                        AppJourney.onboarding()
                    case .login:
                        AppJourney.login
                    }
                }
            }
        }
    }
}

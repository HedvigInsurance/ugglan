import Authentication
import Forever
import Foundation
import Home
import Market
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

@available(iOS 16.0, *)
struct MainJourney: View {

    public init() {}

    @ViewBuilder
    var body: some View {
        if Dependencies.featureFlags().isUpdateNecessary {
            UpdateAppScreen(onSelected: {})
            //            UpdateAppScreen.journey.onPresent {
            //                Launch.shared.completeAnimationCallbacker.callAll()
            //            }
        } else {
            switch ApplicationState.currentState {
            case .onboardingChat, .onboarding, .offer:
                //                AppJourney.notLoggedIn
                EmptyView()
            case .loggedIn:

                //                TabView {
                //                    HomeView(claimsContent: EmptyView(), memberId: {
                //                        return ""
                //                    },
                //                             pathState: .init()
                //                    )
                //                        .tabItem {
                //                            Label(
                //                                title: { hText("Home") },
                //                                icon: { Image(uiImage: hCoreUIAssets.homeTab.image) }
                //                            )
                //                        }
                //
                //                    ForeverView()
                //                         .tabItem {
                //                             Label(
                //                                 title: { hText("Forever") },
                //                                 icon: { Image(uiImage: hCoreUIAssets.foreverTab.image) }
                //                             )
                //                         }
                //                }

                //                AppJourney.loggedIn.onPresent {
                //                    Launch.shared.completeAnimationCallbacker.callAll()
                //                    log.info("Logged in screen", error: nil, attributes: nil)
                //                }
                EmptyView()
            case .impersonation:
                //                AppJourney.impersonationSettings.onPresent {
                //                    Launch.shared.completeAnimationCallbacker.callAll()
                //                }
                EmptyView()
            default:
                EmptyView()
            }
        }
    }

    //    static var main: some JourneyPresentation {
    //        GroupJourney {
    //            if Dependencies.featureFlags().isUpdateNecessary {
    //                UpdateAppScreen.journey.onPresent {
    //                    Launch.shared.completeAnimationCallbacker.callAll()
    //                }
    //            } else {
    //                switch ApplicationState.currentState {
    //                case .onboardingChat, .onboarding, .offer:
    //                    AppJourney.notLoggedIn
    //                case .loggedIn:
    //                    AppJourney.loggedIn.onPresent {
    //                        Launch.shared.completeAnimationCallbacker.callAll()
    //                        log.info("Logged in screen", error: nil, attributes: nil)
    //                    }
    //                case .impersonation:
    //                    AppJourney.impersonationSettings.onPresent {
    //                        Launch.shared.completeAnimationCallbacker.callAll()
    //                    }
    //                default:
    //                    AppJourney.notLoggedIn
    //                }
    //            }
    //        }
    //        .onAction(UgglanStore.self) { action in
    //            if action == .showLoggedIn {
    //                AppJourney.loggedIn
    //            }
    //        }
    //        .onAction(AuthenticationStore.self) { action in
    //            if action == .navigationAction(action: .impersonation) {
    //                AppJourney.impersonationSettings.onPresent {
    //                    Launch.shared.completeAnimationCallbacker.callAll()
    //                }
    //            }
    //        }
    //    }
}

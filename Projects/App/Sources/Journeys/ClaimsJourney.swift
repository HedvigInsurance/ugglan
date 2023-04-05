import Claims
import Contacts
import Embark
import Flow
import Foundation
import Home
import Odyssey
import OdysseyKit
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {

    static func claimDetailJourney(claim: Claim) -> some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: ClaimDetailView(claim: claim),
            options: [.embedInNavigationController]
        ) { action in
            DismissJourney()
        }
        .inlineTitle()
        .configureTitle(L10n.ClaimStatus.title)
    }

    static func claimsInfoJourney() -> some JourneyPresentation {
        Journey(ClaimsInfoPager())
            .onAction(ClaimsStore.self) { action in
                if case .submitNewClaim = action {
                    DismissJourney()
                }
            }
    }

    @JourneyBuilder
    static func startClaimsJourney(from origin: ClaimsOrigin) -> some JourneyPresentation {
        //        if hAnalyticsExperiment.claimsFlow {
        if true {
            ClaimJourneys.showCommonClaimIfNeeded(origin: origin) { newOrigin in
                honestyPledge(from: newOrigin)
                //                {
                //                    AppJourney.notificationJourney {
                //                        AppJourney.getScreenForAction(for: .openPhoneNumberScreen(phoneNumber: ""))
                ////                        ContinueJourney().onPresent {
                ////                            let store: ClaimsStore = globalPresentableStoreContainer.get()
                ////                            store.send(.startClaim(from: newOrigin.id))
                ////                        }.onAction(ClaimsStore.self) { action in
                ////                            getScreenForAction(for: action)
                ////                        }
                //                    }
            }
        } else if hAnalyticsExperiment.odysseyClaims {
            ClaimJourneys.showCommonClaimIfNeeded(origin: origin) { newOrigin in
                odysseyClaims(from: newOrigin)
            }
        } else {
            claimsJourneyPledgeAndNotificationWrapper { redirect in
                switch redirect {
                case .chat:
                    AppJourney.claimsChat()
                        .hidesBackButton
                        .withJourneyDismissButton
                case .close:
                    DismissJourney()
                case .menu:
                    ContinueJourney()
                case .mailingList:
                    DismissJourney()
                case .offer:
                    DismissJourney()
                case .quoteCartOffer:
                    DismissJourney()
                }
            }
        }
    }

    private static func honestyPledge(from origin: ClaimsOrigin) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: LoadingViewWithContent(.startClaim(from: origin.id)) { HonestyPledge() },
            style: .detented(.scrollViewContentSize, modally: false)
        ) { action in
            if case .didAcceptHonestyPledge = action {
                let status = UNUserNotificationCenter.current().status()
                if case .notDetermined = status {
                    Journey(
                        ClaimsAskForPushnotifications(),
                        style: .detented(.large, modally: false)
                    ) { _ in
                        PopJourney()
                            .onPresent {
                                let store: ClaimsStore = globalPresentableStoreContainer.get()
                                store.send(.startClaim(from: origin.id))
                            }
                    }
                } else {
                    ContinueJourney()
                        .onPresent {
                            let store: ClaimsStore = globalPresentableStoreContainer.get()
                            store.send(.startClaim(from: origin.id))
                        }
                }
            } else {
                ClaimJourneys.getScreenForAction(for: action, withHidesBack: true)
            }
        }
        .onAction(ClaimsStore.self) { action, nav in
            if case .startClaim = action {
                nav.viewController.navigationController?.popToViewController(nav.viewController, animated: true)

            }
        }
    }

    private static func odysseyClaims(from origin: ClaimsOrigin) -> some JourneyPresentation {
        return OdysseyRoot(
            name: "mainRouter",
            initialURL: "/automation-claim",
            scopeValues: origin.initialScopeValues
        ) { destinationURL in
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            store.send(.odysseyRedirect(url: destinationURL))
        }
        .disposableHostingJourney
        .setStyle(.detented(.large))
        .setOptions([])
        .onAction(ClaimsStore.self) { action in
            if case let .odysseyRedirect(urlString) = action {
                switch urlString {
                case "hedvig://chat":
                    AppJourney.claimsChat()
                        .hidesBackButton
                        .withJourneyDismissButton
                case "hedvig://close":
                    DismissJourney()
                default:
                    ContinueJourney()
                        .onPresent {
                            guard let url = URL(string: urlString), url.isHTTP else {
                                return
                            }

                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                }
            }
        }
    }

    static func commonClaimDetailJourney(claim: CommonClaim) -> some JourneyPresentation {
        Journey(
            CommonClaimDetail(claim: claim),
            style: .detented(.medium, .large),
            options: .defaults
        )
        .onAction(ClaimsStore.self) { action in
            if case .submitNewClaim = action {
                DismissJourney()
            }
        }
        .withJourneyDismissButton
    }

    @JourneyBuilder
    private static func claimsJourneyPledgeAndNotificationWrapper<RedirectJourney: JourneyPresentation>(
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        HonestyPledge.journey(style: .detented(.scrollViewContentSize)) {
            AppJourney.notificationJourney {
                let embark = Embark(name: "claims")
                AppJourney.embark(embark, redirectJourney: redirectJourney).hidesBackButton
            }
        }
    }
}

extension AppJourney {
    static func notificationJourney<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping () -> Next
    ) -> some JourneyPresentation {
        Journey(NotificationLoader(), style: .detented(.large, modally: false)) { authorization in
            switch authorization {
            case .notDetermined:
                Journey(
                    ClaimsAskForPushnotifications(),
                    style: .detented(.large, modally: false)
                ) { _ in
                    next()
                }
            default:
                next()
            }
        }
    }
}

extension AppJourney {
    static func embark<RedirectJourney: JourneyPresentation>(
        _ embark: Embark,
        style: PresentationStyle = .default,
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        Journey(embark, style: style) { redirect in
            redirectJourney(redirect)
        }
    }
}
extension JourneyPresentation {
    func sendActionOnDismiss<S: Store>(_ storeType: S.Type, _ action: S.Action) -> Self {
        return self.onDismiss {
            let store: S = self.presentable.get()

            store.send(action)
        }
    }
}

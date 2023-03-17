import Claims
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
    static func claimJourney(from origin: ClaimsOrigin) -> some JourneyPresentation {
        GroupJourney { context in
            switch origin {
            case .generic:
                HostingJourney(
                    ClaimsStore.self,
                    rootView: SelectCommonClaim(),
                    style: .detented(.large),
                    options: [
                        .defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.always),
                        .allowSwipeDismissAlways,
                    ]
                ) { action in
                    if case let .commonClaimOriginSelected(origin) = action {
                        startClaimsJourney(from: origin)
                    }
                }
                .withDismissButton
            case .commonClaims:
                startClaimsJourney(from: origin)
            }
        }
        .onPresent {
            hAnalyticsEvent.claimFlowType(
                claimType: hAnalyticsExperiment.odysseyClaims ? .automation : .manual
            )
            .send()
        }
    }

    @JourneyBuilder
    private static func startClaimsJourney(from origin: ClaimsOrigin) -> some JourneyPresentation {
        AppJourney.claimsJourneyPledgeAndNotificationWrapper(from: origin) { redirect in
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

    @JourneyBuilder
    private static func claimsJourneyPledgeAndNotificationWrapper<RedirectJourney: JourneyPresentation>(
        from origin: ClaimsOrigin,
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        if hAnalyticsExperiment.odysseyClaims {
            odysseyClaims(from: origin).withJourneyDismissButton
        } else {
            HonestyPledge.journey {
                AppJourney.notificationJourney {
                    let embark = Embark(name: "claims")
                    AppJourney.embark(embark, redirectJourney: redirectJourney).hidesBackButton
                }
                .withJourneyDismissButton
            }
        }
    }

    static func odysseyClaims(from origin: ClaimsOrigin) -> some JourneyPresentation {
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
